#!/usr/bin/env python3
"""Generate standardised Catppuccin Mocha README header/footer blocks for Tagnet repos."""
import argparse, textwrap, json

PALETTE = {
    "teal": "94e2d5",
    "sky": "89dceb",
    "sapphire": "74c7ec",
    "blue": "89b4fa",
    "mauve": "cba6f7",
    "green": "a6e3a1",
    "peach": "fab387",
    "yellow": "f9e2af",
    "text": "cdd6f4",
    "subtext0": "a6adc8",
    "surface0": "313244",
    "base": "1e1e2e",
    "mantle": "181825",
    "crust": "11111b",
}

STATUS_COLORS = {
    "stable": "a6e3a1",
    "wip": "f9e2af",
    "experimental": "fab387",
    "archived": "9399b2",
    "beta": "89b4fa",
}


def header(owner, repo, branch="main", status="stable", accent1="teal", accent2="sky", extra_shields=None):
    """Return the standard header markdown block."""
    c = PALETTE
    status_color = STATUS_COLORS.get(status.lower(), STATUS_COLORS["wip"])
    extras = "\n".join(extra_shields) if extra_shields else ""
    parts = [
        "<!-- TAGNET README HEADER — Catppuccin Mocha — do not edit by hand -->",
        '<div align="center">',
        "",
        f"[![License](https://img.shields.io/github/license/{owner}/{repo}?color={c['surface0']}&labelColor={c['crust']}&label=License&style=flat-square)](https://github.com/{owner}/{repo}/blob/{branch}/LICENSE)",
        f"[![Status](https://img.shields.io/badge/Status-{status}-{status_color}?labelColor={c['crust']}&style=flat-square)](https://github.com/{owner}/{repo}/pulse)",
        f"[![Version](https://img.shields.io/github/v/release/{owner}/{repo}?color={c['surface0']}&labelColor={c['crust']}&label=Version&style=flat-square)](https://github.com/{owner}/{repo}/releases)",
    ]
    if extras:
        parts.append(extras)
    parts += [
        f"[![Repo](https://img.shields.io/badge/Repo-{repo}-{c[accent1]}?labelColor={c['crust']}&style=flat-square&logo=github&logoColor={c[accent1]})](https://github.com/{owner}/{repo})",
        f"[![Tagnet](https://img.shields.io/badge/By-Tagnet-{c[accent2]}?labelColor={c['crust']}&style=flat-square&logo=tag&logoColor={c[accent2]})](https://tagnet.dev)",
        "",
        "</div>",
        "<!-- TAGNET README HEADER — end -->",
    ]
    return "\n".join(parts)


def footer(owner, repo):
    """Return the standard footer markdown block."""
    return textwrap.dedent(f"""\
        <!-- TAGNET README FOOTER — start -->

        <div align="center">

        **Like this work? Fuel the next widget / experiment / scaffold.**

        [![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-%23FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/tagnet.net)
        [![Patreon](https://img.shields.io/badge/Support-Patreon-ff424d?logo=patreon&logoColor=white&style=for-the-badge)](https://www.patreon.com/VeritasExMachina?utm_campaign=creatorshare_creator)

        <small>Crafted with caffeine, curiosity, and a Catppuccin palette · © {owner}</small>

        </div>
        <!-- TAGNET README FOOTER — end -->
    """)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate Tagnet README header/footer")
    parser.add_argument("owner", help="GitHub owner/organisation")
    parser.add_argument("repo", help="Repository name")
    parser.add_argument("--branch", default="main")
    parser.add_argument("--status", default="stable", choices=list(STATUS_COLORS))
    parser.add_argument("--accent1", default="teal", choices=list(PALETTE))
    parser.add_argument("--accent2", default="sky", choices=list(PALETTE))
    parser.add_argument("--extra-shield", action="append", default=None, help="Additional markdown shield line")
    args = parser.parse_args()
    print(header(args.owner, args.repo, args.branch, args.status, args.accent1, args.accent2, args.extra_shield))
    print()
    print(footer(args.owner, args.repo))
