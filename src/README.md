# Network Service Scanner GUI

A native Linux GUI application for scanning network services using nmap.

## Features

- Auto-discover network interfaces
- Scan for open ports on devices in your network
- Predefined common ports (SSH, HTTP, HTTPS, FTP, etc.)
- Custom port scanning
- Clean, native Linux interface using GTK

## Requirements

- Python 3
- PyGObject (GTK bindings for Python)
- nmap
- GTK3

## Installation

### Automatic Installation

Run the installation script:

```bash
./install.sh
```

### Manual Installation

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

## Usage

Run the application:

```bash
python3 main.py
```

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

## Directory Structure

- `main.py` - Application entry point
- `ui/` - User interface components
- `core/` - Core functionality (scanning, configuration)
- `assets/` - Images and other assets
- `config/` - Configuration files

## License

MIT