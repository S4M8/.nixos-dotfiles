#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
HOSTNAME="${1:-$(hostname)}"
PASS=0
FAIL=0

check() {
  local desc="$1"
  local result="$2"
  if [ "$result" = true ]; then
    echo "  ✓ $desc"
    PASS=$((PASS + 1))
  else
    echo "  ✗ $desc"
    FAIL=$((FAIL + 1))
  fi
}

echo "═══════════════════════════════════════════"
echo "  NixOS Config Validation"
echo "  Host: $HOSTNAME"
echo "═══════════════════════════════════════════"
echo ""

# ── NixOS version check ─────────────────────────────────────────
FLAKE_VERSION=$(grep 'nixpkgs.url' "$REPO_DIR/flake.nix" | grep -oP 'nixos-\d+\.\d+' || echo "unknown")
check "NixOS version in flake: $FLAKE_VERSION" true

# ── /etc/nixos symlink ──────────────────────────────────────────
SYMLINK_TARGET=$(readlink -f /etc/nixos 2>/dev/null || echo "")
check "/etc/nixos symlinked to repo" [ "$SYMLINK_TARGET" = "$REPO_DIR" ]

# ── Host files exist ────────────────────────────────────────────
check "hosts/$HOSTNAME/hardware-configuration.nix exists" [ -f "$REPO_DIR/hosts/$HOSTNAME/hardware-configuration.nix" ]
check "hosts/$HOSTNAME/base.nix exists" [ -f "$REPO_DIR/hosts/$HOSTNAME/base.nix" ]
check "hosts/$HOSTNAME/modules.nix exists" [ -f "$REPO_DIR/hosts/$HOSTNAME/modules.nix" ]

# ── Secrets ─────────────────────────────────────────────────────
if [ -f /etc/age/keys.txt ] || [ -f ~/.config/age/key.txt ]; then
  check "Age key exists" true
else
  check "Age key exists" false
fi

check "Surfshark VPN config exists" [ -f /etc/wireguard/surfshark.conf ]

# ── SSH key ─────────────────────────────────────────────────────
check "SSH key present" [ -f ~/.ssh/id_ed25519 ]

# ── Duplicate hostnames ─────────────────────────────────────────
DUPLICATES=$(grep -c "networking.hostName" "$REPO_DIR"/hosts/*/base.nix 2>/dev/null || echo 0)
check "No duplicate hostnames" [ "$(echo "$DUPLICATES" | wc -l)" -le 1 ]

# ── Flake check ─────────────────────────────────────────────────
echo ""
echo "Running nix flake check..."
cd "$REPO_DIR"
if nix flake check 2>&1; then
  check "nix flake check passes" true
else
  check "nix flake check passes" false
fi

echo ""
echo "──────────────────────────────────────────"
echo "  $PASS passed, $FAIL failed"
echo "──────────────────────────────────────────"

exit $FAIL
