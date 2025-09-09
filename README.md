# Network Service Scanner GUI

A native Linux GUI application for scanning network services using nmap.

![NSS GUI](screenshot.png)

This is a complete rewrite of the original [Network-Service-Scanner](https://github.com/madroots/Network-Service-Scanner) bash script with a modern graphical interface.

## Features

- Auto-discover network interfaces
- Scan for open ports on devices in your network
- Predefined common ports (SSH, HTTP, HTTPS, FTP, etc.)
- Custom port scanning
- Clean, native Linux interface using GTK
- Non-blocking UI operations
- Real-time results display

## Installation

### AppImage (Recommended)

Download the latest AppImage from the [releases page](https://github.com/madroots/Network-Service-Scanner/releases) and make it executable:

```bash
chmod +x Network-Service-Scanner-*.AppImage
./Network-Service-Scanner-*.AppImage
```

### From Source

1. Install system dependencies:
   ```bash
   # Ubuntu/Debian
   sudo apt install python3 python3-pip python3-gi python3-gi-cairo gir1.2-gtk-3.0 nmap
   
   # Fedora
   sudo dnf install python3 python3-pip python3-gobject gtk3 nmap
   
   # Arch Linux
   sudo pacman -S python python-pip python-gobject gtk3 nmap
   ```

2. Install Python dependencies:
   ```bash
   pip3 install -r requirements.txt
   ```

3. Run the application:
   ```bash
   python3 main.py
   ```

## Usage

1. Use "Auto Discover Network" to automatically detect your network
2. Or manually enter an IP range (e.g., 192.168.1.0/24)
3. Select the ports you want to scan
4. Click "Start Scan"
5. View results in the table

## Development

To run the application during development:

```bash
python3 main.py
```

## Building AppImage

This repository includes GitHub Actions to automatically build AppImages for each release.

To build manually, you can use the included build script:

```bash
./build/build-appimage.sh
```

## Directory Structure

- `main.py` - Application entry point
- `ui/` - User interface components
- `core/` - Core functionality (scanning, configuration)
- `build/` - Build scripts and configurations

## License

MIT