# MikroTik CHR Installer Script

This repository contains a script that allows you to install different versions of MikroTik CHR on a VPS. You can choose one from the list of available versions and do the installation process automatically.

## Attributes

- Display the list of available versions in two columns
- Download the version selected by the user
- Display the percentage of progress in the installation process
- Automatic network settings and autorun script creation

## prerequisites

- Linux operating system
- Root access to the system

## How to use

1. Direct execution of the script using `curl`:

 ```bash
 bash -c "$(curl -L https://raw.githubusercontent.com/o-k-l-l-a/Install-MikroTik-CHR-on-VPS/main/setup.sh)"
 ```

2. The list of available versions of MikroTik will be displayed to you. Select the version you want and press Enter.

3. The script will automatically download, extract, mount and install the selected version. The progress percentage of the installation process will be displayed to you.

## Attention

- The script needs root access to work. Make sure you are running the script as root or using `sudo'.
- The installation process may take a few minutes. Please be patient and let the script run completely.

## Support

If you encounter any problems or have any questions, you can contact us via the Issues page on GitHub.

## license

This project is published under the MIT license. For more information, refer to the LICENSE file.

---

By running this script, you can easily install different versions of MikroTik CHR on your VPS and benefit from the features of this powerful operating system.
