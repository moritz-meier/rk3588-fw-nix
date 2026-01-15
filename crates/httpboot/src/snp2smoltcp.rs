use core::cmp::min;

use log::error;
use smoltcp::{
    phy::{ChecksumCapabilities, Device, DeviceCapabilities, Medium, RxToken, TxToken},
    time::Instant,
    wire::EthernetAddress,
};
use uefi::proto::network::snp::SimpleNetwork;
use uefi::{Status, proto::network::EfiMacAddr};

pub struct SnpDevice<'phy, const MTU_SIZE: usize> {
    phy: &'phy mut SimpleNetwork,
}

impl<'phy, const MTU_SIZE: usize> SnpDevice<'phy, MTU_SIZE> {
    pub fn new(phy: &'phy mut SimpleNetwork) -> Self {
        Self { phy }
    }

    pub fn current_address(&self) -> EthernetAddress {
        self.phy.mode().current_address.to_eth_addr()
    }

    pub fn permanent_address(&self) -> EthernetAddress {
        self.phy.mode().permanent_address.to_eth_addr()
    }
}

impl<'phy, const MTU_SIZE: usize> Device for SnpDevice<'phy, MTU_SIZE> {
    type RxToken<'a>
        = SnpRxToken<MTU_SIZE>
    where
        Self: 'a;

    type TxToken<'a>
        = SnpTxToken<'a, MTU_SIZE>
    where
        Self: 'a;

    fn receive(&mut self, _timestamp: Instant) -> Option<(Self::RxToken<'_>, Self::TxToken<'_>)> {
        let mut rx = Self::RxToken {
            buf: [0u8; MTU_SIZE],
            len: 0,
        };

        let recv = self.phy.receive(&mut rx.buf, None, None, None, None);
        match recv {
            Ok(len) => {
                rx.len = len;
                let tx = Self::TxToken { phy: &mut self.phy };
                Some((rx, tx))
            }
            Err(e) if e.status() == Status::NOT_READY => None,
            Err(e) => {
                error!("error during rx: {e}");
                None
            }
        }
    }

    fn transmit(&mut self, _timestamp: Instant) -> Option<Self::TxToken<'_>> {
        Some(Self::TxToken { phy: self.phy })
    }

    fn capabilities(&self) -> DeviceCapabilities {
        let mut caps = DeviceCapabilities::default();
        caps.checksum = ChecksumCapabilities::default();
        caps.max_burst_size = Some(1);
        caps.max_transmission_unit = min(self.phy.mode().max_packet_size as usize, MTU_SIZE);
        caps.medium = Medium::Ethernet;

        caps
    }
}

pub struct SnpRxToken<const MTU_SIZE: usize> {
    buf: [u8; MTU_SIZE],
    len: usize,
}

impl<const MTU_SIZE: usize> RxToken for SnpRxToken<MTU_SIZE> {
    fn consume<R, F>(self, f: F) -> R
    where
        F: FnOnce(&[u8]) -> R,
    {
        f(&self.buf[..self.len])
    }
}

pub struct SnpTxToken<'phy, const MTU_SIZE: usize> {
    phy: &'phy mut SimpleNetwork,
}

impl<'phy, const MTU_SIZE: usize> TxToken for SnpTxToken<'phy, MTU_SIZE> {
    fn consume<R, F>(self, len: usize, f: F) -> R
    where
        F: FnOnce(&mut [u8]) -> R,
    {
        let mut buf = [0u8; MTU_SIZE];
        let res = f(&mut buf[..len]);

        let tx_res = self.phy.transmit(0, &mut buf[..len], None, None, None);
        if let Err(e) = tx_res {
            error!("tx error: {}", e)
        }

        loop {
            let re_buf = match self.phy.get_recycled_transmit_buffer_status() {
                Ok(re_buf) => re_buf,
                Err(e) => {
                    error!("tx buf recycle error: {}", e);
                    continue;
                }
            };

            let Some(re_buf) = re_buf else {
                continue;
            };

            if re_buf.as_ptr() != (&mut buf as *mut _) {
                error!("tx buf recycle error!");
                break;
            }

            break;
        }

        res
    }
}

pub trait EfiMacAddrExt<T> {
    fn to_eth_addr(&self) -> T;
}

impl EfiMacAddrExt<EthernetAddress> for EfiMacAddr {
    fn to_eth_addr(&self) -> EthernetAddress {
        let mut addr = EthernetAddress([0; 6]);
        addr.0[..6].copy_from_slice(&self.0[..6]);
        addr
    }
}

pub trait EthernetAddressExt<T> {
    fn to_efi_mac_addr(&self) -> T;
}

impl EthernetAddressExt<EfiMacAddr> for EthernetAddress {
    fn to_efi_mac_addr(&self) -> EfiMacAddr {
        let mut addr = EfiMacAddr([0; 32]);
        addr.0[..6].copy_from_slice(&self.0[0..6]);
        addr
    }
}
