#!/bin/bash
# =============================================================================
# Bash Aliases - System Information
# Shortcuts für Hardware- und Systeminformationen
# =============================================================================

# Hardware Übersicht kompakt
alias hardware_short="lshw -short"
alias hardware_full="sudo lshw"
alias pci_devices="lspci"
alias usb_devices="lsusb"
alias block_devices="lsblk"
alias drive_info="hdparm -I /dev/sda"
alias smart_info="sudo smartctl -a /dev/sda"
