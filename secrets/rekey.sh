#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SECRETS_DIR="$REPO_DIR/secrets"
PUBKEYS_DIR="$SECRETS_DIR/pubkeys"

echo "═══════════════════════════════════════════"
echo "  Agenix Rekey"
echo "  Re-encrypts all secrets to all known"
echo "  machine public keys."
echo "═══════════════════════════════════════════"
echo ""

# ── Locate age identity ─────────────────────────────────────────
IDENTITY=""
for candidate in "$HOME/.config/age/key.txt" "/etc/age/keys.txt"; do
  if [ -f "$candidate" ]; then
    IDENTITY="$candidate"
    break
  fi
done

if [ -z "$IDENTITY" ]; then
  echo "✗ No age identity found."
  echo "  Generate one first:"
  echo "    mkdir -p ~/.config/age"
  echo "    nix shell nixpkgs#age -c age-keygen -o ~/.config/age/key.txt"
  exit 1
fi
echo "  Identity: $IDENTITY"

# ── Collect recipient public keys ───────────────────────────────
RECIPIENTS=()
RECIPIENT_NAMES=()
for keyfile in "$PUBKEYS_DIR"/*.age; do
  [ -f "$keyfile" ] || continue
  key=$(tr -d '[:space:]' < "$keyfile")
  name=$(basename "$keyfile" .age)
  if [ -n "$key" ]; then
    RECIPIENTS+=("$key")
    RECIPIENT_NAMES+=("$name")
    echo "  Recipient: $name → $key"
  fi
done

if [ ${#RECIPIENTS[@]} -eq 0 ]; then
  echo "✗ No recipient keys found in $PUBKEYS_DIR"
  echo "  Add a machine's public key:"
  echo "    echo 'age1...' > $PUBKEYS_DIR/<hostname>.age"
  exit 1
fi

echo ""
echo "  Re-encrypting to ${#RECIPIENTS[@]} recipient(s)..."
echo ""

# ── Build recipient args ────────────────────────────────────────
RECIPIENT_ARGS=()
for key in "${RECIPIENTS[@]}"; do
  RECIPIENT_ARGS+=(-r "$key")
done

# ── Re-encrypt each secret ──────────────────────────────────────
count=0
for secret in "$SECRETS_DIR"/*.age; do
  name=$(basename "$secret" .age)
  case "$name" in
    pubkeys|rekey) continue ;;
  esac
  [ -f "$secret" ] || continue

  tmp=$(mktemp)
  age -d -i "$IDENTITY" -o "$tmp" "$secret" 2>/dev/null || {
    echo "  ✗ $name.age — decryption failed (not encrypted to this key?)"
    rm -f "$tmp"
    continue
  }

  age "${RECIPIENT_ARGS[@]}" -o "$secret" "$tmp"
  rm -f "$tmp"
  echo "  ✓ $name.age"
  count=$((count + 1))
done

echo ""
echo "  Done — $count secret(s) re-encrypted."
echo ""
echo "  Commit and push the updated .age files:"
echo "    git add secrets/ && git commit -m 'Re-encrypt secrets' && git push"
