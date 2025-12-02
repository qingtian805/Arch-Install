## arch installation script

**WARNING: mainly for personal usage, use it at your own risk**

Usage:

1. Install Ventory on USB drive
2. Copy arch installation script to USB drive
3. Normally use Arch LiveCD in Ventory to install Arch
4. Use these scripts

Sequance:
1. `main.sh`: This will help to configure Live CD(WLAN, time sync, check boot method, select mirror)
2. `basic_configure.sh`: This will install a basic system, including NetworkManager. Following scripts will be called by this script
    * `disk.sh`: Partitioning utility(assume NO swap partition)
    * `graphic.sh`: Video card driver utility
    * `bootloader.sh`: Bootloader utility
3. ``

> Some restrictions for myself:
> * Only use Y as default when asking whether to do something during installation
>   * BUT in tuning scripts, I may use N as default for better comprehension.
> * Module scripts NEVER asks whether to do something, this should be done in main script, ask how to do something
> * Process that could fail should be wrapped in a module script
