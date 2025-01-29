#!/usr/bin/env sh

rkdeveloptool db result/rk3588_spl_loader_v1.18.113.bin
rkdeveloptool ef

rkdeveloptool rd
sleep 2

rkdeveloptool db result/rk3588_spl_loader_v1.18.113.bin
rkdeveloptool wl 0 result/boot.bin

rkdeveloptool rd
