#!/bin/bash

# Check UEFI
if [ ! -e /sys/firmware/efi/fw_platform_size ]; then
	echo "You seems using BIOS. However, but this script is designed for UEFI."
	exit
fi

source ./utils.sh

# Flags
ldr_mpoint=""
efi_mpoint="/mnt/boot"
removable="N"
detect_entry="N"

cmd_line=""
package=""

detect_partition() {
	local efi_list=$(lsblk -o PARTTYPE,MOUNTPOINT \
		| grep -i c12a7328-f81f-11d2-ba4b-00a0c93ec93b)
	local ldr_list=$(lsblk -o PARTTYPE,MOUNTPOINT \
		| grep -i bc13c2ff-59e6-4262-a352-b275fd6f7172)

	#Check the mount point within /mnt as root
	efi_mpoint=$(echo "${efi_list}" | awk '{print $2}' | grep "/mnt/"\
		| sed 's/\/mnt//g')
	ldr_mpoint=$(echo "${ldr_list}" | awk '{print $2}' | grep "/mnt/"\
		| sed 's/\/mnt//g')

	if [ -z "${efi_mpoint}" ]; then
		echo "[BOOTLOADER] ERROR: EFI partition not detected"
		exit 1
	fi
}

systemd_boot() {
	local root_uuid=$(lsblk -o NAME,MOUNTPOINT,UUID | grep "/mnt " | awk '{print $3}')

	local options=""
	local loader_conf=$(cat <<- EOF
		timeout 5
		EOF
	)
	local systemd_entry=$(cat <<- EOF
		title   Arch Linux (linux)
		linux   /vmlinuz-linux
		initrd  /initramfs-linux.img
		options root=PARTUUID=${root_uuid} zswap.enabled=0 rw rootfstype=ext4
		EOF
	)

	# Removable
	if [ "${removable}" == "Y" ]; then
		options="${options} --variables=no"
	fi

	# Systemd-boot auto enables os-probe
	if [ "${detect_entry}" == "N" ]; then
		loader_conf=$(sed '$a auto-entries no' <<< ${loader_conf})
	fi

	# xbootldr
	if [ "${ldr_mpoint}" != "" ]; then
		options="${options} --boot-path=${ldr_mpoint} --esp-path=${efi_mpoint}"
	fi

	# install to system
	echo "Installing systemd-boot..."
	$CMD_BASE bootctl install ${options}

	echo "Configuring systemd-boot..."
	$CMD_BASE echo '${loader_conf}' > ${efi_mpoint}/loader/loader.conf

	echo "Setting up entry..."
	# Get root partition UUID and generate base entry config


	# Write linux entry
	$CMD_BASE echo "${conf}" > ${efi_mpoint}/loader/entries/linux.conf
	# Write fallback entry if used
	conf_fallback=$(sed "s/initramfs-linux/initramfs-linux-fallback/g" <<< "${conf}")
	if [ -e "/mnt/boot/initramfs-linux-fallback.img" ]; then
		$CMD_BASE echo "${conf_fallback}" > ${efi_mpoint}/loader/entries/linux-fallback.conf
	fi

	cmd_line="/usr/bin/bootctl install ${options}"
}

grub() {
	local options="--target=x86_64-efi --bootloader-id=GRUB"
	local dependencies="efibootmgr"

	# Removable
	if [ $removable = "Y" ]; then
		options="${options} --removable"
	fi

	# Os-prober
	if [ ${detect_entry} = "Y" ]; then
		dependencies="${dependencies} os-prober"
		$CMD_BASE sed "s/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub
	fi

	# Grub need no to specify xbootldr
	options="${options} --efi-directory=${efi_mpoint} "

	echo "Installing grub..."
	# package and dependencies
	$CMD_BASE pacman -S grub
	$CMD_BASE pacman -S --asdeps ${dependencies}

	# install to system and configure
	cmd_line="/bin/sh -c '/usr/bin/grub-install ${options};"
	cmd_line+="/usr/bin/grub-mkconfig -o /boot/grub/grub.cfg'"

	$CMD_BASE $cmd_line
}

alpm_hook() {

	local hook=$(cat <<- EOF
		[Trigger]
		Operation = Upgrade
		Operation = Install
		Type = Package
		Target = ${package}

		[Action]
		Description = Upgrading ${package}...
		When = PostTransaction
		Depends = ${package}
		Exec = ${cmd_line}
		EOF
	)

	if ! [ -d "/mnt/etc/pacman.d/hooks" ]; then
		mkdir /mnt/etc/pacman.d/hooks
	fi
	$CMD_BASE tee /mnt/etc/pacman.d/hooks/bootloader.hook <<< ${hook} > /dev/null
}

# ------ MAIN ----------
detect_partition

read -p "Is the device removable from system? [y/N]" opt
if [ "$opt" != "y" -a "$opt" = "Y" ]; then
	removable="N"
else
	removable="Y"
fi

read -p "Detect other OS in esp? [Y/n]" opt
if [ "$opt" != "n" -a "$opt" = "N" ]; then
	detect_entry="Y"
else
	detect_entry="N"
fi

bootloader=$(input "Bootloader you want to use [systemd-boot/grub]:")
if   [ "$bootloader" = "systemd-boot" ]; then
	package="systemd"
	systemd_boot
elif [ "$bootloader" = "grub" ]; then
	package="grub"
	grub
else
	echo "Unsupported bootloader!"
	exit 1
fi

echo "Configuring alpm hook..."
alpm_hook

