# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a collection of macOS keychain CLI tools that provide a simplified interface to the macOS `security` command. The tools are designed to work with an `APP_NAME` environment variable for organizing secrets.

## Architecture

The project consists of five main bash scripts:

- `kc-get`: Retrieves values from keychain using `security find-generic-password`
- `kc-set`: Stores values in keychain using `security add-generic-password` (with deletion of existing keys)
- `kc-list`: Lists all keys associated with the current `APP_NAME` using `security dump-keychain`
- `kc-apps`: Lists all unique APP_NAMEs from keychain using `security dump-keychain`
- `kc-dup`: Copies keys from one APP_NAME to another using get/set operations

All tools follow the same pattern:
1. Check for `APP_NAME` environment variable
2. Validate command-line arguments
3. Execute appropriate `security` command
4. Handle errors gracefully

## Key Requirements

- `APP_NAME` environment variable must be set for all operations
- All scripts use `set -euo pipefail` for strict error handling
- Scripts are designed to be installed via Homebrew from a private tap

## Common Commands

Since this is a collection of bash scripts without build processes:

```bash
# Make scripts executable (if needed)
chmod +x kc-get kc-list kc-set kc-apps kc-dup

# Test the tools locally
export APP_NAME="test-app"
./kc-set TEST_KEY "test-value"
./kc-get TEST_KEY
./kc-list
./kc-apps
./kc-dup source-app TEST_KEY
```

## Testing

Test manually by setting `APP_NAME` and running the commands. The tools interact with the actual macOS keychain, so testing requires:

1. Setting a test `APP_NAME`
2. Using `kc-set` to store test values
3. Using `kc-get` to retrieve values
4. Using `kc-list` to verify stored keys
5. Cleanup by deleting test entries if needed

## Shell Integration

The tools support shell completion for zsh and bash as documented in the README.md.