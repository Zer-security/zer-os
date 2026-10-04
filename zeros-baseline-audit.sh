#!/bin/bash
set -euo pipefail

ROOT="/home/zerkoth/zeros/rootfs-workspace"

sudo chroot "$ROOT" /bin/bash -c '
{
echo "ZER OS CORE NET/PRIV AUDIT BASELINE"
date --iso-8601=seconds
echo "=== PACKAGES ==="
dpkg-query -W -f="${binary:Package}\t${Status}\t${Version}\n" \
  nftables tor libpam-tmpdir sudo
echo "=== PERMISSIONS ==="
stat -c "%a %U:%G %n" \
  /etc/nftables.conf /etc/tor/torrc /etc/sudoers
echo "=== NFTABLES ==="
cat /etc/nftables.conf
echo "=== TOR CONFIG ==="
cat /etc/tor/torrc
echo "=== SERVICES ==="
systemctl is-enabled nftables.service 2>&1 || true
systemctl is-enabled tor.service 2>&1 || true
echo "=== SUDOERS CHECK ==="
visudo -c 2>&1
echo "=== NFT CONFIG CHECK ==="
nft -c -f /etc/nftables.conf 2>&1
echo "=== PAM TMPDIR ==="
grep -RniE "pam_tmpdir|tmpdir" /etc/pam.d 2>/dev/null || true
echo "=== TOR CONFIG CHECK ==="
tor --verify-config -f /etc/tor/torrc 2>&1 || true
} > /root/core-netpriv-audit-baseline.txt
sha256sum /root/core-netpriv-audit-baseline.txt
'
