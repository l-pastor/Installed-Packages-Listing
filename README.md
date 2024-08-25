
# Installed Packages Listing

This repository contains two Bash scripts for listing installed packages on a Debian-based system. One script lists packages installed via `APT`, and the other lists packages installed via `Rust`.

## Scripts Overview

### 1. installed_apt_packages_list.sh

This script parses the APT history log to generate a list of installed packages, along with their installation dates and versions.

**Usage:**

```bash
./installed_apt_packages_list.sh [options]
```

**Options:**

- `-h` : Display the help message.
- `-f <file>` : Specify the APT log file to analyze. Default: `/var/log/apt/history.log`.
- `-o <file>` : Specify the output file. By default, the result is displayed in the terminal.

**Example:**

```bash
./installed_apt_packages_list.sh -f /var/log/apt/history.log -o result.txt
```
This command analyzes the specified log file and saves the results to `result.txt`.

### 2. installed_rust_packages_list.sh

This script lists packages installed via `cargo`, showing their installation dates and versions. It checks for the presence of Rust on the system and can save the results to a file if specified.

**Usage:**

```bash
./installed_rust_packages_list.sh [options]
```

**Options:**

- `-h` : Display the help message.
- `-o <file>` : Specify the output file. By default, the result is displayed in the terminal.

**Example:**

```bash
./installed_rust_packages_list.sh -o result.txt
```
This command lists Rust packages and saves the results to `result.txt`.

## Requirements

- **Bash**: Both scripts must be run with Bash.
- **APT**: `installed_apt_packages_list.sh` is designed for Debian-based systems with APT.
- **Rust and Cargo**: `installed_rust_packages_list.sh` requires Rust and Cargo to be installed on the system.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
