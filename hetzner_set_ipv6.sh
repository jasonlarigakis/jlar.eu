#!/usr/bin/env bash
#
# set-hetzner-ipv6.sh
#
# Reads the assigned IPv6 subnet + gateway from the Hetzner Cloud metadata
# endpoint and configures them on the primary network interface.
#
# Why this exists: Hetzner routes a /64 to each server but does NOT hand the
# address out via SLAAC/DHCPv6 — it has to be set statically. Reading it from
# metadata at runtime means the config keeps working even if the server is
# rebuilt and gets a different subnet.
#
# Idempotent: uses `ip ... replace`, so it is safe to run repeatedly.

set -euo pipefail

METADATA_URL="http://169.254.169.254/hetzner/v1/metadata"

log() { printf '[hetzner-ipv6] %s\n' "$*" >&2; }

# --- Fetch metadata --------------------------------------------------------
metadata="$(curl -fsS --retry 5 --retry-delay 2 --max-time 30 "$METADATA_URL")" || {
  log "failed to fetch metadata from $METADATA_URL"
  exit 1
}

# --- Parse the static IPv6 CIDR, e.g. 2a01:4ff:f0:f32d::1/64 ---------------
# Matches a run of hex/colons followed by /prefix, then keeps only the one
# containing a colon (excludes the IPv4 entry, which has dots not colons).
ipv6_cidr="$(printf '%s\n' "$metadata" \
  | grep -oE '[0-9a-fA-F:]+/[0-9]+' \
  | grep ':' \
  | head -n1)" || true

if [[ -z "${ipv6_cidr}" ]]; then
  log "no static IPv6 address found in metadata; nothing to do"
  exit 0
fi

# --- Parse the gateway (always fe80::1 on Hetzner, but read it anyway) ------
gateway="$(printf '%s\n' "$metadata" \
  | grep -oiE 'fe80::[0-9a-f]+' \
  | head -n1)" || true
gateway="${gateway:-fe80::1}"

# --- Pick the interface ----------------------------------------------------
# Prefer the NIC whose MAC matches the metadata (handles servers that also
# have a private-network interface). Fall back to the default-route NIC,
# then to eth0.
mac="$(printf '%s\n' "$metadata" \
  | grep -oiE '([0-9a-f]{2}:){5}[0-9a-f]{2}' \
  | head -n1)" || true

iface=""
if [[ -n "${mac}" ]]; then
  iface="$(ip -o link show | grep -i "${mac}" | awk -F': ' '{print $2}' | head -n1)" || true
fi
if [[ -z "${iface}" ]]; then
  iface="$(ip -4 route show default 2>/dev/null | awk '{print $5; exit}')" || true
fi
iface="${iface:-eth0}"

log "interface=${iface} address=${ipv6_cidr} gateway=${gateway}"

# --- Apply (idempotent) ----------------------------------------------------
ip -6 addr replace "${ipv6_cidr}" dev "${iface}"
ip -6 route replace default via "${gateway}" dev "${iface}" onlink

log "done"
