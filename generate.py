# /// script
# requires-python = ">=3.13"
# dependencies = ["ocx-mirror-sdk"]
#
# [tool.uv.sources]
# ocx-mirror-sdk = { url = "https://github.com/ocx-sh/ocx-mirror-sdk/releases/download/v0.4.0/ocx_mirror_sdk-0.4.0-py3-none-any.whl" }
# ///
# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 The OCX Authors

"""Generate url_index JSON for Elvish shell.

Elvish publishes NO binary assets on its GitHub releases. Binaries live on the
dl.elv.sh CDN with this URL scheme:

    https://dl.elv.sh/{os}-{arch}/elvish-v{version}.{ext}

where ext is .zip for windows, .tar.gz for all other platforms. The filename
portion (excluding the path prefix) is IDENTICAL across platforms — only the
URL path distinguishes them. To avoid asset-dict key collisions, we synthesize
a platform-tagged asset name:

    name = f"elvish-v{version}-{token}.{ext}"     # synthesized, no collision
    url  = f"https://dl.elv.sh/{token}/elvish-v{version}.{ext}"   # real CDN

The .tar.gz/.zip extension in the synthesized name is preserved so the mirror
pipeline's format-detection logic (driven by extension) works correctly.
"""

import re

from ocx_mirror_sdk import IndexBuilder, github

REPO = "elves/elvish"
DIST_URL = "https://dl.elv.sh"
TAG_RE = re.compile(r"^v(?P<version>\d+\.\d+\.\d+)$")

# Floor: 0.21.0 is the first release whose dl.elv.sh layout is verified.
# Older releases either predate the CDN scheme or use an inconsistent layout.
FLOOR = (0, 21, 0)

# ocx platform -> (dl.elv.sh os-arch token, archive extension).
# windows/arm64 does NOT exist upstream — intentionally omitted.
# Exotic Linux arches (386, riscv64) have no OCX mapping — omitted.
PLATFORMS: dict[str, tuple[str, str]] = {
    "linux-amd64": ("linux-amd64", "tar.gz"),
    "linux-arm64": ("linux-arm64", "tar.gz"),
    "darwin-amd64": ("darwin-amd64", "tar.gz"),
    "darwin-arm64": ("darwin-arm64", "tar.gz"),
    "windows-amd64": ("windows-amd64", "zip"),
}


def _version_tuple(version: str) -> tuple[int, int, int]:
    parts = version.split(".")
    return (int(parts[0]), int(parts[1]), int(parts[2]))


def main() -> None:
    index = IndexBuilder()
    for release in github.list_releases(REPO, include_prereleases=False, include_drafts=False):
        match = TAG_RE.match(release.tag_name)
        if not match:
            continue
        version = match.group("version")

        # Skip versions below the floor (pre-CDN or unverified layout).
        if _version_tuple(version) < FLOOR:
            continue

        assets: dict[str, str] = {}
        for _ocx_platform, (token, ext) in PLATFORMS.items():
            # Synthesize a platform-tagged name so the assets dict has unique
            # keys even though the real CDN filenames collide across platforms.
            name = f"elvish-v{version}-{token}.{ext}"
            url = f"{DIST_URL}/{token}/elvish-v{version}.{ext}"
            assets[name] = url

        index.add_version(version, assets=assets, prerelease=release.prerelease)

    index.emit()


if __name__ == "__main__":
    main()
