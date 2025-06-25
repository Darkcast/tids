# Enable Touch ID sudo Setup script

<div align="center">
    <img src="tids.png" alt="tids_banner" style="width: 70%; max-width: 700px; height: auto;">
</div>

## Description

Enable Touch ID for sudo on macOS

Get Fingerprint Authentication for Elevated Terminal Commands. \
The `tids.sh` script simplifies the process of enabling Touch ID for sudo commands on macOS. It allows you to use secure fingerprint authentication as a password replacement for elevated privileges, making your command-line more convenient and secure. Eliminating manual repetitive password entry for administrative tasks with ease.

## Features

* Robust and dependable – Built to perform consistently
* Blazing fast – Optimized for quick execution
* Pure Bash – No external dependencies required

## Requirements

* macOS operating system with Touch ID support.
* Administrator privileges to modify system files.

## Usage

To use the script, download it and make it executable:

#### Download:
```bash
git clone https://github.com/Darkcast/tids
cd tids
```
#### chmod:
```bash
chmod +x tids.sh
```

### Run it with the desired option(s):

```bash
./tids.sh [ARGUMENTS]

Note: ARGUMENTS are optional

-f, --force: Force reconfiguration even if sudo_local already exists. This will create a backup of your existing sudo_local file.
-l, --logging: Enable detailed logging with timestamps.
-h, --help: Show the help message and exit.

```
## Usage Example
Configure Touch ID:
```bash
./tids.sh [ARGUMENTS are optional]
```


# Troubleshooting

* **This script is designed for macOS only**: Ensure you are running the script on a macOS machine.

* **"Template file '/etc/pam.d/sudo_local.template' not found."**: This file should exist on macOS systems with Touch ID. If it's missing, your system might be misconfigured, or Touch ID sudo might not be officially supported on your specific macOS version.

* **"Failed to copy template to '/etc/pam.d/sudo_local'. Please ensure you have administrator/sudo privileges."**: You need to run the script with `sudo` or have sufficient permissions to modify files in `/etc/pam.d/`.

* **"Expected commented pam_tid.so line not found."**: The template file's content might have changed in a new macOS version. You may need to manually inspect `/etc/pam.d/sudo_local.template` and adjust the script's `sed` command if necessary.

* **Touch ID still asks for password**:

    * Verify that the `auth sufficient pam_tid.so` line is present and *not* commented out in `/etc/pam.d/sudo_local`.

    * Ensure Touch ID is enabled and configured in System Settings/Preferences.

    * Restart your terminal or computer to ensure changes take effect.

## Reverting Changes

If you need to revert the changes made by this script:

1.  **Remove the configured file**:

    ```bash
    sudo rm /etc/pam.d/sudo_local

    ```

2.  **Restore from backup (if one was created)**:
    If a backup was created (e.g., `/etc/pam.d/sudo_local.backup.<timestamp>`), you can restore it:

    ```bash
    sudo mv /etc/pam.d/sudo_local.backup.<timestamp> /etc/pam.d/sudo_local

    ```

    Replace `<timestamp>` with the actual timestamp from your backup file.


<br>
<br>

# Licencing 
This project is strictly for **NON-COMMERCIAL USE**, including personal and educational purposes. Commercial exploitation is **not permitted** unless authorized by the developer.
