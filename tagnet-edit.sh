#!/bin/bash
# ══════════════════════════════════════════════════════════════════════════════
#  TAGNET EDITOR — Quick UI for editing tagnet.net + git push
#  Run this from the tagnet.net repo folder
# ══════════════════════════════════════════════════════════════════════════════
set -euo pipefail

SKY='\033[0;36m'; TEAL='\033[0;35m'; GRN='\033[0;32m'; RED='\033[0;31m'; RST='\033[0m'
REPO_DIR="$HOME/Dropbox/9-PROJECTS/tagnet.net"

cd "$REPO_DIR" 2>/dev/null || { echo -e "${RED}[!] Cannot cd to $REPO_DIR${RST}"; exit 1; }

banner() {
  echo ""
  echo -e "  ${SKY}╔══[ tagnet.net editor ]════════════════════════╗${RST}"
  echo -e "  ${TEAL}║  Edit · Commit · Push · Live                   ║${RST}"
  echo -e "  ${SKY}╚═══════════════════════════════════════════════╝${RST}"
  echo ""
}

show_menu() {
  echo -e "  ${TEAL}Options:${RST}"
  echo ""
  echo -e "    ${GRN}1)${RST} Edit page in nano       (index.html)"
  echo -e "    ${GRN}2)${RST} Change email / tagline  (quick replace)"
  echo -e "    ${GRN}3)${RST} Add a project link      (prompt for name + url)"
  echo -e "    ${GRN}4)${RST} Commit & push            (git add + commit + push)"
  echo -e "    ${GRN}5)${RST} Preview locally         (python http.server)"
  echo -e "    ${RED}0)${RST} Exit"
  echo ""
}

edit_page() {
  local editor="${EDITOR:-nano}"
  which "$editor" >/dev/null 2>&1 || editor="nano"
  echo -e "${SKY}[*] Opening index.html in $editor...${RST}"
  echo -e "${TEAL}    Tip: Look for --text-- blocks to edit.${RST}"
  sleep 1
  "$editor" index.html
  echo -e "${GRN}[✓] Editor closed. Run option 4 to push.${RST}"
}

quick_replace() {
  echo -e "${SKY}[*] Current values in index.html:${RST}"
  grep -o 'mailto:[^"]*' index.html | head -1 | sed 's/mailto:/Email: /'
  grep -o 'research at[^<]*' index.html | head -1 | sed 's/^/Tagline: /'
  echo ""
  read -rp "New email (or press Enter to keep): " new_email
  read -rp "New tagline (or press Enter to keep): " new_tagline

  if [[ -n "$new_email" ]]; then
    # Update mailto link text and footer
    sed -i "s|mailto:[^\"]*|mailto:$new_email|g" index.html
    sed -i "s|<a href=\"mailto:[^\"]*\">[^\x3C]*</a>|<a href=\"mailto:$new_email\">$new_email</a>|g" index.html
    echo -e "${GRN}[✓] Email updated${RST}"
  fi

  if [[ -n "$new_tagline" ]]; then
    sed -i "s|research at the edge of order and noise|$new_tagline|g" index.html
    echo -e "${GRN}[✓] Tagline updated${RST}"
  fi
}

add_link() {
  echo -e "${SKY}[*] Add a new project link to the page${RST}"
  read -rp "Project name (e.g. SimAE): " name
  read -rp "GitHub URL: " url
  read -rp "Icon character (e.g. ◉ ◈ ◆): " icon

  [[ -z "$name" || -z "$url" ]] && { echo -e "${RED}[!] Name and URL required${RST}"; return; }
  [[ -z "$icon" ]] && icon="◆"

  python3 tagnet_link_adder.py "$name" "$url" "$icon"
  echo -e "${GRN}[✓] Run option 4 to push.${RST}"
}

commit_push() {
  echo -e "${SKY}[*] Git status:${RST}"
  git status --short
  echo ""
  read -rp "Commit message: " msg
  [[ -z "$msg" ]] && msg="update tagnet.net"
  git add index.html tagnet_link_adder.py tagnet-edit.sh 2>/dev/null || git add index.html
  git commit -m "$msg"
  git push
  echo ""
  echo -e "${GRN}[✓] Pushed to GitHub. Cloudflare auto-deploys in ~30s.${RST}"
  echo -e "${TEAL}    Check: https://tagnet.net${RST}"
}

preview() {
  echo -e "${SKY}[*] Starting local preview on http://localhost:8765${RST}"
  echo -e "${TEAL}    Press Ctrl+C to stop${RST}"
  python3 -m http.server 8765 &
  local pid=$!
  sleep 1
  xdg-open http://localhost:8765 2>/dev/null || echo "Open http://localhost:8765 in your browser"
  wait $pid
}

main() {
  while true; do
    banner
    show_menu
    read -rp "  Pick an option [0-5]: " choice
    echo ""

    case "$choice" in
      1) edit_page ;;
      2) quick_replace ;;
      3) add_link ;;
      4) commit_push ;;
      5) preview ;;
      0) echo "Exiting."; exit 0 ;;
      *) echo -e "${RED}Invalid choice.${RST}" ;;
    esac

    echo ""
    read -rp "Press Enter to continue..."
  done
}

main
