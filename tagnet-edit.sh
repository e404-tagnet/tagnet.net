#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  TAGNET EDITOR — Quick UI for editing tagnet.net + git push
#  ══════════════════════════════════════════════════════════════════════════════
set -uo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../7-SCRIPTS/Launchers/runbook-lib.sh"

REPO_DIR="$HOME/Dropbox/9-PROJECTS/tagnet.net"

tagnet_edit_banner() {
    rb_ascii_banner "$RB_SKY" \
            "  ███████████   █████████     █████████   ██████   ██████ ██████████ ███████████" \
            " ░█░░░███░░░█  ███░░░░░███   ███░░░░░███ ░░██████ ░░███  ░███░░░░░ █░█ ░░███░░░█" \
            " ░   ░███  ░  ░███    ░███  ███     ░░░   ░███░███ ░███  ░███  █ ░      ░███  ░ " \
            "     ░███     ░███████████ ░███           ░███░░███░███  ░██████        ░███    " \
            "     ░███     ░███░░░░░███ ░███    █████  ░███ ░░██████  ░███░░█        ░███    " \
            "     ░███     ░███    ░███ ░░███   ░░░███ ░███  ░░█████  ░███░      █   ░███    " \
            "     █████    █████   █████ ░░█████████  █████  ░░█████  ░███████████   █████   " \
            "    ░░░░░    ░░░░░   ░░░░░   ░░░░░░░░░  ░░░░░    ░░░░░   ░░░░░░░░░░    ░░░░░    "
}

cd "$REPO_DIR" 2>/dev/null || { rb_err "Cannot cd to $REPO_DIR"; rb_pause; exit 1; }

edit_page() {
  local editor="${EDITOR:-nano}"
  command -v "$editor" >/dev/null 2>/dev/null || editor="nano"
  rb_info "Opening index.html in $editor..."
  echo -e "  ${RB_DIM}Tip: Look for --text-- blocks to edit.${RB_R}"
  sleep 1
  "$editor" index.html
  rb_info "Editor closed. Run 'Commit & push' to push."
}

quick_replace() {
  rb_info "Current values in index.html:"
  grep -o 'mailto:[^"]*' index.html | head -1 | sed 's/mailto:/Email: /'
  grep -o 'research at[^\u003C]*' index.html | head -1 | sed 's/^/Tagline: /'
  echo ""
  read -rp "  New email (or press Enter to keep): " new_email
  read -rp "  New tagline (or press Enter to keep): " new_tagline

  if [[ -n "$new_email" ]]; then
    sed -i "s|mailto:[^\"]*|mailto:$new_email|g" index.html
    sed -i "s|\u003ca href=\"mailto:[^\"]*\"\u003e[^\x3C]*\u003c/a\u003e|\u003ca href=\"mailto:$new_email\"\u003e$new_email\u003c/a\u003e|g" index.html
    rb_info "Email updated"
  fi

  if [[ -n "$new_tagline" ]]; then
    sed -i "s|research at the edge of order and noise|$new_tagline|g" index.html
    rb_info "Tagline updated"
  fi
}

add_link() {
  rb_info "Add a new project link to the page"
  read -rp "  Project name (e.g. SimAE): " name
  read -rp "  GitHub URL: " url
  read -rp "  Icon character (e.g. ◉ ◈ ◆): " icon

  [[ -z "$name" || -z "$url" ]] && { rb_err "Name and URL required"; return; }
  [[ -z "$icon" ]] && icon="◆"

  python3 tagnet_link_adder.py "$name" "$url" "$icon"
  rb_info "Run 'Commit & push' to push."
}

commit_push() {
  rb_info "Git status:"
  git status --short
  echo ""
  read -rp "  Commit message: " msg
  [[ -z "$msg" ]] && msg="update tagnet.net"
  git add index.html tagnet_link_adder.py tagnet-edit.sh 2>/dev/null || git add index.html
  git commit -m "$msg"
  git push
  echo ""
  rb_info "Pushed to GitHub. Cloudflare auto-deploys in ~30s."
  echo -e "  ${RB_DIM}Check: https://tagnet.net${RB_R}"
}

preview() {
  rb_info "Starting local preview on http://localhost:8765"
  echo -e "  ${RB_DIM}Press Ctrl+C to stop${RB_R}"
  python3 -m http.server 8765 &
  local pid=$!
  sleep 1
  xdg-open http://localhost:8765 2>/dev/null || echo "Open http://localhost:8765 in your browser"
  wait $pid
}

main() {
  while true; do
    local opts=(
      "EDIT PAGE          open index.html in editor"
      "QUICK REPLACE      change email / tagline"
      "ADD PROJECT LINK   prompt for name + url + icon"
      "COMMIT & PUSH      git add + commit + push"
      "PREVIEW LOCAL      python http.server + open browser"
      "BACK               return to runbooks"
    )
    rb_menu "TAGNET EDITOR" "${opts[@]}" || break
    case $RB_MENU_RESULT in
      0) edit_page ;;
      1) quick_replace ;;
      2) add_link ;;
      3) commit_push ;;
      4) preview ;;
      *) break ;;
    esac
    rb_pause
  done

  tput cnorm 2>/dev/null || true
  clear
}

main
