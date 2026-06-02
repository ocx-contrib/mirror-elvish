# tests/smoke.star — stable across upstream releases.
# Elvish is a cross-platform shell. Assert on the contract (exit code, version
# shape, hermetic computation), never on help/version prose.

TOOL = "elvish.exe" if ocx.target_platform.os == ocx.os.Windows else "elvish"

# Tier 1 + 2: liveness + version SHAPE (not a vendor string, not the exact version).
# `-version` (single dash) prints the version string to stdout, e.g. `0.21.0+official`.
r_version = ocx.run(TOOL, "-version")
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# Tier 3: functional behavior on hermetic input.
# Elvish arithmetic: `(+ 40 2)` evaluates to 42. Input is fully controlled by
# this test — the result is a stable contract independent of upstream wording.
r_arith = ocx.run(TOOL, "-c", "echo (+ 40 2)")
expect.ok(r_arith)
expect.contains(r_arith.stdout, "42")

# String echo: assert our controlled input string appears in output.
r_echo = ocx.run(TOOL, "-c", "echo hello-elvish")
expect.ok(r_echo)
expect.contains(r_echo.stdout, "hello-elvish")
