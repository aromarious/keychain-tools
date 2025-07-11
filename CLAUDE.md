# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a collection of macOS keychain CLI tools that provide a simplified interface to the macOS `security` command. The tools are designed to work with an `APP_NAME` environment variable for organizing secrets.

## Architecture

The project consists of six main bash scripts:

- `kc-get`: Retrieves values from keychain using `security find-generic-password`
- `kc-set`: Stores values in keychain using `security add-generic-password` (with deletion of existing keys)
- `kc-list`: Lists all keys associated with the current `APP_NAME` using `security dump-keychain`
- `kc-apps`: Lists all unique APP_NAMEs from keychain using `security dump-keychain` with advanced filtering
- `kc-dup`: Copies keys from one APP_NAME to another using get/set operations
- `kc-delete`: Safely deletes keys from keychain with existence verification

All tools follow the same pattern:
1. Check for `APP_NAME` environment variable (except `kc-apps`)
2. Validate command-line arguments
3. Execute appropriate `security` command
4. Handle errors gracefully

## Key Features

### Advanced Filtering in kc-apps
The `kc-apps` command uses sophisticated AWK-based parsing to filter out unwanted entries:
- WiFi network passwords (identified by `desc="AirPort network password"` and `svce="AirPort"`)
- WiFi analytics data (`svce="WiFiAnalytics"`)
- System entries (Apple/com.apple prefixes)
- Network-related entries (Akamai, Fastly)
- Long hash strings and MAC addresses
- Various system identifiers and tokens

### Complete CRUD Operations
- **Create/Update**: `kc-set` for storing values
- **Read**: `kc-get` for retrieving values, `kc-list` for listing keys
- **Delete**: `kc-delete` for safe key removal
- **Utility**: `kc-apps` for app discovery, `kc-dup` for copying between apps

## Key Requirements

- `APP_NAME` environment variable must be set for all operations
- All scripts use `set -euo pipefail` for strict error handling
- Scripts are designed to be installed via Homebrew from a private tap

## Common Commands

Since this is a collection of bash scripts without build processes:

```bash
# Make scripts executable (if needed)
chmod +x kc-get kc-list kc-set kc-apps kc-dup kc-delete

# Test the tools locally
export APP_NAME="test-app"
./kc-set TEST_KEY "test-value"
./kc-get TEST_KEY
./kc-list
./kc-apps
./kc-dup source-app TEST_KEY
./kc-delete TEST_KEY
```

## Testing

Test manually by setting `APP_NAME` and running the commands. The tools interact with the actual macOS keychain, so testing requires:

1. Setting a test `APP_NAME`
2. Using `kc-set` to store test values
3. Using `kc-get` to retrieve values
4. Using `kc-list` to verify stored keys
5. Using `kc-delete` to remove test entries
6. Using `kc-apps` to verify clean app listing (should exclude WiFi/system entries)

Always clean up test data using `kc-delete` to avoid cluttering the keychain.

## Version History

- **v1.3.0**: Added `kc-delete` command with shell completion support
- **v1.2.0**: Major WiFi filtering improvements in `kc-apps` using structural parsing
- **v1.1.0**: Added `kc-apps` and `kc-dup` commands
- **v1.0.x**: Initial release with basic CRUD operations

## Shell Integration

The tools support comprehensive shell completion for zsh and bash as documented in the README.md:
- `kc-get`, `kc-set`, `kc-delete`: Complete with existing keys from current `APP_NAME`
- `kc-dup`: First argument completes with app names, second with keys from selected app
- `kc-apps`: No completion needed (lists all apps)
- `kc-list`: Can accept app name as argument for cross-app key listing
