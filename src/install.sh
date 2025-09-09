#!/bin/bash

# NSS GUI Installation Script

echo "Installing NSS GUI..."

# Check if we're on a Debian-based system
if command -v apt &> /dev/null; then
    echo "Installing dependencies on Debian/Ubuntu..."
    sudo apt update
    sudo apt install -y python3 python3-pip python3-gi python3-gi-cairo gir1.2-gtk-3.0 nmap
elif command -v dnf &> /dev/null; then
    echo "Installing dependencies on Fedora..."
    sudo dnf install -y python3 python3-pip python3-gobject gtk3 nmap
elif command -v pacman &> /dev/null; then
    echo "Installing dependencies on Arch Linux..."
    sudo pacman -S python python-pip python-gobject gtk3 nmap
else
    echo "Warning: Unsupported package manager. Please install dependencies manually:"
    echo "  - Python 3"
    echo "  - PyGObject"
    echo "  - GTK3"
    echo "  - nmap"
fi

# Install Python dependencies
echo "Installing Python dependencies..."
pip3 install -r requirements.txt

echo "Installation complete!"
echo "Run the application with: python3 main.py"