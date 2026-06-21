#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
HOSTNAME="${1:-}"
TIMEZONE="${2:-America/Denver}"
ASSUME_YES="${3:-}"

echo "═══════════════════════════════════════════"
echo "  NixOS Machine Bootstrap"
echo "  s4m8 NixOS Dotfiles"
echo "═══════════════════════════════════════════"
echo ""

# ── Step 1: Identity ────────────────────────────────────────────
if [ -z "$HOSTNAME" ]; then
  read -r -p "Hostname: " HOSTNAME
fi
echo "  Hostname → $HOSTNAME"

if [ "$TIMEZONE" = "America/Denver" ] && [ -z "$2" ]; then
  read -r -p "Timezone [$TIMEZONE]: " TZ_INPUT
  TIMEZONE="${TZ_INPUT:-$TIMEZONE}"
fi
echo "  Timezone → $TIMEZONE"

# ── Step 2: Hardware detection ──────────────────────────────────
HOST_DIR="$REPO_DIR/hosts/$HOSTNAME"
mkdir -p "$HOST_DIR"

if [ ! -f "$HOST_DIR/hardware-configuration.nix" ]; then
  echo ""
  echo "Step 2/6 — Hardware detection"
  sudo nixos-generate-config --show-hardware-config > "$HOST_DIR/hardware-configuration.nix"
  echo "  → Saved to hosts/$HOSTNAME/hardware-configuration.nix"
fi

# ── Step 3: Age key ────────────────────────────────────────────
echo ""
echo "Step 3/6 — Age key (agenix)"
if [ ! -f ~/.config/age/key.txt ]; then
  echo "  Generating age key..."
  mkdir -p ~/.config/age
  age-keygen -o ~/.config/age/key.txt
  echo "  → ~/.config/age/key.txt created"
fi
PUBKEY=$(grep "public key" ~/.config/age/key.txt | cut -d: -f2 | xargs)
echo "  Public key: $PUBKEY"
echo "  Add this key to your repo's secrets by running:"
echo "    agenix -r $PUBKEY"

# ── Step 4: Create host configs ─────────────────────────────────
echo ""
echo "Step 4/6 — Creating host configs"

cat > "$HOST_DIR/base.nix" <<EOF
{ ... }: {
  networking.hostName = "$HOSTNAME";
  time.timeZone = "$TIMEZONE";
}
EOF
echo "  → hosts/$HOSTNAME/base.nix"

if [ ! -f "$HOST_DIR/modules.nix" ]; then
  cat > "$HOST_DIR/modules.nix" <<'EOF'
{ ... }: {
  imports = [ ];
}
EOF
  echo "  → hosts/$HOSTNAME/modules.nix (empty — customize as needed)"
fi

cat > "$HOST_DIR/home.nix" <<EOF
{ ... }: {
  imports = [
    ../../home.nix
  ];
}
EOF
echo "  → hosts/$HOSTNAME/home.nix"

# ── Step 5: Symlink /etc/nixos ──────────────────────────────────
echo ""
echo "Step 5/6 — Symlink /etc/nixos"
if [ "$(readlink -f /etc/nixos)" != "$REPO_DIR" ]; then
  sudo rm -rf /etc/nixos
  sudo ln -s "$REPO_DIR" /etc/nixos
  echo "  → /etc/nixos → $REPO_DIR"
else
  echo "  → Already symlinked"
fi

# ── Step 6: Rebuild ─────────────────────────────────────────────
echo ""
echo "Step 6/6 — Rebuild"
echo "  Running: nixos-rebuild switch --flake $REPO_DIR#$HOSTNAME"
echo ""
read -r -p "Proceed? [Y/n] " CONFIRM
CONFIRM="${CONFIRM:-Y}"
if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
  sudo nixos-rebuild switch --flake "$REPO_DIR#$HOSTNAME"
  echo ""
  echo "✓ Rebuild successful!"
  echo "  Reboot to complete setup."
else
  echo "  Skipped. Rebuild manually:"
  echo "    sudo nixos-rebuild switch --flake $REPO_DIR#$HOSTNAME"
fi
