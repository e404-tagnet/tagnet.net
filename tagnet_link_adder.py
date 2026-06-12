#!/usr/bin/env python3
"""tagnet_link_adder.py — Insert a new project link into tagnet.net index.html"""
import sys, re

def add_link(name: str, url: str, icon: str = "◆"):
    with open("index.html", "r") as f:
        html = f.read()

    # Build the new link block
    link_block = f'''            <a class="link" href="{url}" target="_blank" rel="noopener">
                <span class="link-label">
                    <span class="link-icon">{icon}</span>
                    {name}
                </span>
                <span class="link-arrow">→</span>
            </a>'''

    # Find the .links div and insert before its closing </div>
    links_start = html.find('<div class="links">')
    if links_start == -1:
        print("[!] Could not find .links div")
        sys.exit(1)

    # Find the closing </div> of .links (should be the first </div> after .links start)
    links_end = html.find('</div>', links_start)
    if links_end == -1:
        print("[!] Could not find closing </div> for .links")
        sys.exit(1)

    # Insert the new link before </div>
    html = html[:links_end] + link_block + "\n" + html[links_end:]

    with open("index.html", "w") as f:
        f.write(html)

    print(f"[✓] Added link: {name} → {url}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 tagnet_link_adder.py <name> <url> [icon]")
        sys.exit(1)
    add_link(sys.argv[1], sys.argv[2], sys.argv[3] if len(sys.argv) > 3 else "◆")
