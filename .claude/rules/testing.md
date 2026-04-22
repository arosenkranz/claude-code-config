# Testing

This repository currently has no automated tests. The previous Bats test suite tested the legacy symlink migration scripts, which have been removed as part of the marketplace migration.

If new shell scripts are added to `scripts/`, add corresponding `.bats` tests in `tests/` using the [Bats](https://github.com/bats-core/bats-core) framework.
