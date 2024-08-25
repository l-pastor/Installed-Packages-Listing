
# list_install.sh

A shell script to list all user-installed packages on Debian-based systems, excluding dependencies.

## Overview

`list_install.sh` is a Bash script designed to parse the APT history logs (`/var/log/apt/history.log`) on Debian-based distributions. It generates a list of all packages explicitly installed by the user, excluding any dependencies. The script also provides an option to choose the language (English or French) for its messages and handles date formatting according to the detected system language.

## Features

- Lists all packages explicitly installed by the user.
- Excludes dependencies from the list.
- Supports both English and French language output.
- Handles date formatting according to system language.
- Displays real-time count of processed packages during execution.

## Requirements

- A Debian-based Linux distribution (e.g., Debian, Ubuntu, Linux Mint).
- Bash (this script must be run with Bash).
- Standard Unix utilities like `grep`, `awk`, `sed`, and `date`.

## Usage

### Basic Usage

By default, the script reads from `/var/log/apt/history.log` and outputs the results to `install.txt`:

\`\`\`bash
./list_install.sh
\`\`\`

### Options

- `-h`: Display the help message with usage instructions.
- `-f <file>`: Specify an alternative APT log file to analyze.
- `-o <file>`: Specify the output file. Default is `install.txt`.

### Examples

1. **Analyze the default APT log file and output to `install.txt`:**

   \`\`\`bash
   ./list_install.sh
   \`\`\`

2. **Specify a different log file and output file:**

   \`\`\`bash
   ./list_install.sh -f /path/to/your/logfile.log -o output.txt
   \`\`\`

## Error Handling

- The script checks if the specified APT log file exists. If not, an error message is displayed.
- If the `LANG` environment variable is not set, the script defaults to English.
- The script verifies that it is executed with Bash and will exit with an error message if not.

## Installation

Clone the repository to your local machine:

\`\`\`bash
git clone https://github.com/l-pastor/list_install.sh.git
cd list_install.sh
\`\`\`

Make the script executable:

\`\`\`bash
chmod +x list_install.sh
\`\`\`

## Contributing

Feel free to contribute by opening issues or submitting pull requests.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
