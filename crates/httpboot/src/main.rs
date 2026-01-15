#![no_main]
#![no_std]

use core::time::Duration;

use log::*;

use uefi::boot::stall;
use uefi::prelude::*;
use uefi::proto::network::snp::SimpleNetwork;

use smoltcp::iface::{Config, Interface, PollResult, SocketSet, SocketStorage};
use smoltcp::socket::dhcpv4;
use smoltcp::time::{Duration as SDuration, Instant};
use smoltcp::wire::{HardwareAddress, IpCidr};

use crate::snp2smoltcp::SnpDevice;

mod snp2smoltcp;

#[entry]
fn main() -> Status {
    match main2() {
        Ok(()) => Status::SUCCESS,
        Err(e) => {
            error!("{}", e);
            match e.downcast_ref::<uefi::Error>() {
                Some(e) => e.status(),
                None => Status(0xdeadc0de),
            }
        }
    }
}

fn main2() -> anyhow::Result<()> {
    uefi::helpers::init().unwrap();

    let handle = boot::get_handle_for_protocol::<SimpleNetwork>()?;
    let mut snp = boot::open_protocol_exclusive::<SimpleNetwork>(handle)?;

    if bool::from(snp.mode().media_present_supported) && !bool::from(snp.mode().media_present) {
        info!("snp not present")
    }

    info!("current mac: {:?}", snp.mode().current_address);
    info!("perm mac: {:?}", snp.mode().permanent_address);

    snp.start()?;
    snp.initialize(0, 0)?;

    let mut dev = SnpDevice::<1536>::new(&mut snp);
    let mut iface = Interface::new(
        Config::new(HardwareAddress::Ethernet(dev.current_address())),
        &mut dev,
        shitty_now_from_processor_clock(),
    );

    let mut sockets = [SocketStorage::EMPTY; 8];
    let mut sockets = SocketSet::new(&mut sockets[..]);

    let mut dhcp_socket = dhcpv4::Socket::new();
    dhcp_socket.set_max_lease_duration(Some(SDuration::from_secs(3600)));

    let dhcp = sockets.add(dhcp_socket);

    loop {
        let poll = iface.poll(shitty_now_from_processor_clock(), &mut dev, &mut sockets);
        match poll {
            PollResult::SocketStateChanged => {}
            PollResult::None => continue,
        }

        let event = sockets.get_mut::<dhcpv4::Socket>(dhcp).poll();
        match event {
            None => {}
            Some(dhcpv4::Event::Deconfigured) => {
                info!("dhcp deconfigured");

                iface.update_ip_addrs(|addrs| addrs.clear());
                iface.routes_mut().remove_default_ipv4_route();
            }
            Some(dhcpv4::Event::Configured(config)) => {
                info!("dhcp configured {:?}", config);

                iface.update_ip_addrs(|addrs| {
                    addrs.clear();
                    addrs.push(IpCidr::Ipv4(config.address)).unwrap();
                });

                if let Some(router) = config.router {
                    iface.routes_mut().add_default_ipv4_route(router).unwrap();
                } else {
                    iface.routes_mut().remove_default_ipv4_route();
                }

                for (i, s) in config.dns_servers.iter().enumerate() {
                    debug!("DNS server {}:    {}", i, s);
                }
            }
        }

        stall(Duration::from_millis(1000));
    }

    Ok(())
}

pub fn shitty_now_from_processor_clock() -> Instant {
    #[cfg(target_arch = "x86_64")]
    unsafe {
        Instant::from_micros(core::arch::x86_64::_rdtsc() as i64)
    }

    #[cfg(target_arch = "aarch64")]
    unsafe {
        let mut ticks: u64;
        core::arch::asm!("mrs {}, cntvct_el0", out(reg) ticks);
        Instant::from_micros(ticks as i64)
    }

    #[cfg(not(any(target_arch = "x86_64", target_arch = "aarch64")))]
    panic!("shitty_now_from_processor_clock is not implemented for this platform!");
}
