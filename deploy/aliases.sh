# forlovers' shortcuts on the server, from any folder. It lands in dist/deploy/ with
# every make deploy, and make install adds the line that loads it to ~/.bashrc, once:
# a new shell has the new ones (or: . ~/.bashrc). Same as glowtrail's.

# The deployment folder, two levels above this file, wherever it is.
FORLOVERS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

alias forlovers='cd "$FORLOVERS_DIR"'
alias forlovers-install='make -C "$FORLOVERS_DIR" install'
alias forlovers-status='make -C "$FORLOVERS_DIR" --no-print-directory status'
alias forlovers-logs='make -C "$FORLOVERS_DIR" --no-print-directory logs'

forlovers-help() {
  cat <<EOF
forlovers           aller dans $FORLOVERS_DIR
forlovers-install   après un deploy qui change deploy/ (nginx) : réinstalle ; sans risque à relancer
forlovers-status    le site répond-il, et jusqu'à quand le certificat
forlovers-logs      les visites et les erreurs du site, en direct (Ctrl+C)
forlovers-help      cette liste
EOF
}
