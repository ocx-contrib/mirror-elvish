# NOTICE

This repository packages and redistributes upstream software published by the
[Elvish](https://elv.sh) project ([elves/elvish](https://github.com/elves/elvish)).
The Apache-2.0 license in [`LICENSE`](LICENSE) covers the OCX pipeline files
authored here. It does **not** cover any upstream-derived asset — each
package's redistributed bytes carry their own license, recorded below.

Each package's logo is reproduced for catalog identification only, under
nominative fair use. The marks remain the property of their respective owners
and no endorsement is implied.

| Package | GHCR path | Upstream SPDX |
|---|---|---|
| `elvish` | `ghcr.io/ocx-contrib/elvish/elvish` | `BSD-2-Clause` |

---

## `elvish`

Upstream: <https://github.com/elves/elvish> (binaries distributed via
<https://dl.elv.sh>).
Published to `ghcr.io/ocx-contrib/elvish/elvish`.

| Component | SPDX | Holder |
|---|---|---|
| Elvish (`elvish`) | **BSD-2-Clause** | Copyright (c) Elvish developers and contributors. All rights reserved. |

Permissive; redistribution in binary form is granted provided the copyright
notice, the list of conditions and the disclaimer are reproduced. The CDN
tarballs ship the bare binary with no bundled `LICENSE` file, so the notice is
reproduced above and the terms are those of
<https://github.com/elves/elvish/blob/master/LICENSE>. The published binaries
statically link third-party Go modules under permissive licenses, enumerated in
upstream's `go.mod`.

The Elvish name and logo are used for catalog identification under nominative
fair use; the mark remains the property of the Elvish project.

No modifications are made to any upstream artifact in this repository; they are
republished byte-for-byte inside an OCX bundle.
