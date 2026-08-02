# elvish/tests/smoke.star — stable across upstream releases.
# Elvish is a cross-platform shell. Assert on the contract (exit code, version
# shape, hermetic computation), never on help/version prose.

TOOL = "elvish.exe" if ocx.target_platform.os == ocx.os.Windows else "elvish"

# Point every config/state root at the sandbox so no rc file from the running
# user's account can load and change what these commands do. Elvish reads
# $XDG_CONFIG_HOME/elvish/rc.elv on unix and %APPDATA%\elvish\rc.elv on
# Windows, falling back to $HOME; the whole set is overridden rather than
# reasoning about which one wins on which platform. `env=` is an overlay on the
# composed bundle env, so PATH resolution of TOOL is unaffected.
HERMETIC = {
    "HOME": ocx.scratch_root,
    "APPDATA": ocx.scratch_root,
    "XDG_CONFIG_HOME": ocx.scratch_root,
    "XDG_DATA_HOME": ocx.scratch_root,
    "XDG_STATE_HOME": ocx.scratch_root,
    "XDG_CACHE_HOME": ocx.scratch_root,
}

# Tier 1 + 2: liveness + version SHAPE (not a vendor string, not the exact
# version). `-version` (single dash) prints to stdout, e.g. `0.21.0+official`.
r_version = ocx.run(TOOL, "-version", env = HERMETIC)
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# Tier 3: computed results a stub binary could not fake.
#
# Arithmetic — elvish's `+` is a command, not an operator, so this exercises
# command substitution as well as the numeric builtin.
r_arith = ocx.run(TOOL, "-c", "echo (+ 40 2)", env = HERMETIC)
expect.ok(r_arith)
expect.contains(r_arith.stdout, "42")

# List builtin — `order` sorts a list literal. The input is deliberately
# out of order, so the asserted output only appears if the sort really ran.
r_order = ocx.run(TOOL, "-c", "echo (order [gamma alpha beta])", env = HERMETIC)
expect.ok(r_order)
expect.contains(r_order.stdout, "alpha beta gamma")

# Map builtin — literal, indexing, and arithmetic over the extracted values.
r_map = ocx.run(TOOL, "-c", "var m = [&x=17 &y=8]; echo (* $m[x] $m[y])", env = HERMETIC)
expect.ok(r_map)
expect.contains(r_map.stdout, "136")
