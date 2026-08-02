# mirror-elvish

OCX mirror for [Elvish](https://elv.sh) — a cross-platform shell with an
expressive programming language. One repository, one spec directory per
package.

| Package | Spec | Publishes to | Announced as | Upstream SPDX |
|---|---|---|---|---|
| [elvish](https://github.com/elves/elvish) | [`elvish/mirror.yml`](elvish/mirror.yml) | `ghcr.io/ocx-contrib/elvish/elvish` | `ocx.sh/elvish/elvish` | `BSD-2-Clause` |

Each upstream release is discovered, re-bundled, smoke-tested per
`(version, platform)` and only then pushed with cascade tags, after which the
result is announced into the OCX index.

> This repository previously published the same upstream to the flat coordinate
> `ocx.sh/elvish`. `elvish/elvish` is the grouped successor. Upstream's GitHub
> org is `elves`, which means nothing to anyone who does not already know the
> shell, so the tool names itself.

## Layout

```
mirror-base.yml         repo-wide policy every spec inherits via `extends:`
elvish/
├── mirror.yml          the spec — never at the repo root
├── metadata.json       bundle interface
├── CATALOG.md          → ocx package describe
├── logo.svg / logo.png describe assets, 512px PNG
├── scripts/generate.py the url_index generator
└── tests/smoke.star    Starlark smoke test
```

`LICENSE` and `NOTICE.md` are shared at the root. Logos and the generator are
**not** — each package carries its own, because a repo-root file sits in no
workflow's `paths:` filter, so editing it would publish nothing until some
unrelated change happened to fire.

⚠️ `extends:` is a **shallow** merge of top-level keys. A spec that restates
`platforms:` to change one runner drops every `containers:` entry with it, and
nothing reds — the legs simply stop existing, and every `os.features` claim
goes back to being asserted rather than verified. Restate a block in full or
not at all.

## Where the binaries come from

Elvish ships **no binary assets on its GitHub releases** — the binaries live on
the `dl.elv.sh` CDN at `https://dl.elv.sh/{os}-{arch}/elvish-v{version}.{ext}`.
So this is a `source.type: url_index` mirror: `elvish/scripts/generate.py`
enumerates stable release tags from `elves/elvish` and synthesises the CDN URLs.

The real CDN filename is identical on every platform (only the path segment
differs), so the generator emits a platform-tagged asset **name**
(`elvish-v{V}-{os}-{arch}.{ext}`) to keep the index keys unique while the URL
stays canonical. The anchored `^…$` patterns in `elvish/mirror.yml` are matched
against those synthesised names.

`uv` is the generator's runtime and is pinned in `ocx.toml` as the namespaced
`ocx.sh/astral-sh/uv:0` — never the flat `ocx.sh/uv`, which dies with the
`ocx.sh` host and would leave the generator with nothing to run.

## Platforms

`elvish` publishes five platform entries: both Linux arches, both macOS arches
and `windows/amd64`. There is no aarch64 Windows build on the CDN to mirror.

Upstream builds Elvish as a pure-Go binary, so there is one Linux build per
arch and it is **fully static** — no `PT_INTERP`, no `DT_NEEDED`, and no
musl/glibc variants to choose between. `os.features` states what an artifact
requires *of the host*, so both Linux keys are **bare**: tagging them
`+libc.musl` would be a false requirement that hid them from every glibc host.
The `alpine:3.20` container leg in `mirror-base.yml` is what turns that claim
into evidence; the measurement itself is recorded above the `assets:` block in
`elvish/mirror.yml`.

The version floor is `0.21.0` — the first release whose `dl.elv.sh` layout is
verified.

## Editing

| File | Edit | Regenerate after |
|------|------|------------------|
| `mirror-base.yml`, `elvish/mirror.yml` | hand | yes — see below |
| `elvish/scripts/generate.py` | hand | — |
| `elvish/{metadata.json,CATALOG.md,logo.*}` | hand | — |
| `elvish/tests/smoke.star` | hand | — |
| `.github/workflows/*.yml` | **generated — never hand-edit** | re-run when a spec changes |

```bash
ocx-mirror package pipeline generate ci --spec elvish/mirror.yml
```

**Name every spec.** `--spec` *appends* rather than replaces, so a command
naming a subset silently stops rendering the rest while staying green — and the
drift guard reds on a generated workflow the current spec set no longer
produces.

`verify-generated.yml` exits 65 on drift. If a generated workflow is wrong, the
spec or the renderer template is wrong — fix it there and regenerate.

Run `direnv allow` once to put the pinned toolchain on `PATH`, and invoke
`ocx-mirror` directly — never `ocx run -- ocx-mirror`, which pins
`OCX_BINARY_PIN` to the bootstrap `ocx` and false-reds the nested push.

## The binaries claim

Each tarball holds the single `elvish` binary at the **archive root**
(`strip_components: 0`), so the bundle's only PATH entry is a bare
`${installPath}` — the executable *is* the content root. `bin_scan` only looks
*below* an `${installPath}/<dir>` entry, so `auto`/`verify` is rejected at spec
load with exit 65. `mirror-base.yml` therefore sets `bin_scan: off` and
`elvish/metadata.json` hand-lists `binaries: ["elvish"]` — the blessed shape for
this asset type.

## Required secrets

| Secret | Use |
|--------|-----|
| `OCX_ANNOUNCE_TOKEN` | opens the index pull request from the `ocx-contrib/index` fork |
| `OCX_MIRROR_DISCORD_HOOK` | notify-stage Discord webhook URL |

(Inherited from the `ocx-contrib` org with visibility ALL. GHCR pushes use the
run's own `GITHUB_TOKEN` — no registry secret needed.)

## License

Apache-2.0 — see [`LICENSE`](LICENSE). Upstream assets are out of scope; each
package's redistribution license is recorded in [`NOTICE.md`](NOTICE.md).
