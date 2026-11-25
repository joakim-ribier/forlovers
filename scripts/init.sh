#!/usr/bin/env bash
# Writes .env, setting by setting (those of .env.example): each one asked with its
# current value shown -- .env's if set, else its default -- Enter keeps it. A setting
# left at its default stays commented, as in .env.example; the others are written.
# Same script as glowtrail's, without its secrets (forlovers has none).
set -euo pipefail
cd "$(dirname "$0")/.."

ENV_FILE=.env
EXAMPLE=.env.example

current() { # the value of $1 in .env (uncommented), if any
  [[ -f $ENV_FILE ]] && sed -n "s/^$1=//p" "$ENV_FILE" | tail -1 || true
}

umask 077
tmp=$(mktemp "$ENV_FILE.XXXXXX")
trap 'rm -f "$tmp"' EXIT
changed=0
echo "Chaque réglage avec sa valeur actuelle entre crochets : Entrée la garde."
while IFS= read -r line <&4; do
  # A setting: "KEY=value" or "# KEY=default  # comment".
  if [[ $line =~ ^(#\ )?([A-Z][A-Z0-9_]*)=([^#[:space:]]*) ]]; then
    key=${BASH_REMATCH[2]} def=${BASH_REMATCH[3]} cur=$(current "${BASH_REMATCH[2]}")
    shown=${cur:-$def}
    read -rp "$key [$shown] : " v
    v="${v//[[:space:]]/}"
    v=${v:-$shown}
    [[ $v != "$shown" ]] && changed=1
    if [[ -n $v && $v != "$def" ]]; then
      echo "$key=$v" >> "$tmp"
    else
      echo "# $key=$def" >> "$tmp" # the default: left commented
    fi
  else
    echo "$line" >> "$tmp"
  fi
done 4< "$EXAMPLE"

if [[ $changed == 0 && -f $ENV_FILE ]]; then
  echo ">>> Rien de changé, $ENV_FILE laissé tel quel."
  exit 0
fi
mv "$tmp" "$ENV_FILE"
trap - EXIT
chmod 600 "$ENV_FILE"
echo ">>> $ENV_FILE écrit (droits 600). Serveur du deploy : $(current FORLOVERS_DEPLOY_HOST | sed 's/^$/aucun/')."
