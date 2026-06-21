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

# ── Step 3: Wallpapers ─────────────────────────────────────────
echo ""
echo "Step 3/7 — Wallpapers"
if [ ! -d ~/pictures/wallpapers ]; then
  echo "  Cloning wallpapers..."
  mkdir -p ~/pictures
  git clone https://github.com/S4M8/wallpapers.git ~/pictures/wallpapers
  echo "  → ~/pictures/wallpapers"
else
  echo "  → Already exists"
fi

# ── Step 4: Age key ────────────────────────────────────────────
echo ""
echo "Step 4/7 — Age key (agenix)"
if [ ! -f ~/.config/age/key.txt ]; then
  echo "  Generating age key..."
  mkdir -p ~/.config/age
  age-keygen -o ~/.config/age/key.txt
  echo "  → ~/.config/age/key.txt created"
fi
PUBKEY=$(grep "public key" ~/.config/age/key.txt | cut -d: -f2 | xargs)
echo "  Public key: $PUBKEY"
echo ""
echo "  ── To register this machine for secret decryption ──"
echo "  1. On a machine already in the repo, save this key:"
echo "     echo '$PUBKEY' > ~/.nixos-dotfiles/secrets/pubkeys/$HOSTNAME.age"
echo ""
echo "  2. Run rekey.sh to re-encrypt all secrets:"
echo "     cd ~/.nixos-dotfiles && bash secrets/rekey.sh"
echo ""
echo "  3. Commit and push:"
echo "     git add secrets/ && git commit -m \"Add $HOSTNAME public key\" && git push"
echo ""
echo "  4. Pull on this machine, then rebuild:"
echo "     cd ~/.nixos-dotfiles && git pull && sudo nixos-rebuild switch"

# ── Step 5: Create host configs ─────────────────────────────────
echo ""
echo "Step 5/7 — Creating host configs"

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

# ── Step 6: Symlink /etc/nixos ──────────────────────────────────
echo ""
echo "Step 6/7 — Symlink /etc/nixos"
if [ "$(readlink -f /etc/nixos)" != "$REPO_DIR" ]; then
  sudo rm -rf /etc/nixos
  sudo ln -s "$REPO_DIR" /etc/nixos
  echo "  → /etc/nixos → $REPO_DIR"
else
  echo "  → Already symlinked"
fi

# ── Step 7: Rebuild ─────────────────────────────────────────────
echo ""
echo "Step 7/7 — Rebuild"
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
