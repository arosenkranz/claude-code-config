# Testing

This repository uses Bats (Bash Automated Testing System) for testing shell scripts.

## Running Tests

```bash
# Run all tests
bats tests/

# Run specific test file
bats tests/install.bats

# Verbose output
bats tests/ --tap
```

## Test Structure

Tests are organized in three main files:
- `tests/install.bats` - Installation script tests
- `tests/sync.bats` - Sync command tests
- `tests/validation.bats` - Validation tests

Each test runs in an isolated temporary directory to prevent affecting real system configurations.

## Writing Tests

Test Pattern:
1. **Arrange**: Prepare test data
2. **Act**: Execute the script
3. **Assert**: Verify expected outcomes

## Helper Functions

The `tests/test_helper.bash` provides utilities:
- `setup_test_env` / `teardown_test_env` - Environment management
- `create_fake_skill` / `create_fake_agent` - Test data creation
- `run_install` / `run_sync` - Script execution
- `assert_symlink` / `assert_dir` - Result validation

## Best Practices

- Test both success and failure scenarios
- Verify dry-run mode leaves systems unchanged
- Confirm repeated executions work correctly
- Organize related tests logically

## CI Integration

GitHub Actions automatically runs the full test suite on pushes and pull requests.
