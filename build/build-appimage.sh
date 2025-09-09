#!/bin/bash

# AppImage build script for NSS GUI

set -e

# Create build directory
mkdir -p AppDir/usr/bin
mkdir -p AppDir/usr/lib
mkdir -p AppDir/usr/share/applications
mkdir -p AppDir/usr/share/icons/hicolor/256x256/apps

# Copy application files
cp -r main.py ui core AppDir/usr/bin/
cp requirements.txt AppDir/usr/bin/
cp -r assets AppDir/usr/bin/

# Create desktop entry
cat > AppDir/usr/share/applications/nss-gui.desktop << EOF
[Desktop Entry]
Name=Network Service Scanner
Comment=Scan for open ports on your network
Exec=main.py
Icon=nss-gui
Terminal=false
Type=Application
Categories=Network;Security;
EOF

# Copy desktop entry to root of AppDir for AppImage
cp AppDir/usr/share/applications/nss-gui.desktop AppDir/

# Copy icon
cp assets/nss-gui.svg AppDir/usr/share/icons/hicolor/256x256/apps/nss-gui.png
cp assets/nss-gui.svg AppDir/

# Create AppRun script
cat > AppDir/AppRun << 'EOF'
#!/bin/bash

# Determine the directory where this script is located
APPDIR="$(dirname "$(readlink -f "$0")")"

# Set up environment
export PYTHONPATH="$APPDIR/usr/bin:$PYTHONPATH"
export LD_LIBRARY_PATH="$APPDIR/usr/lib:$LD_LIBRARY_PATH"

# Run the application
python3 "$APPDIR/usr/bin/main.py" "$@"
EOF

chmod +x AppDir/AppRun

# Download AppImageTool if not present
if [ ! -f appimagetool-x86_64.AppImage ]; then
    wget -O appimagetool-x86_64.AppImage "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
    chmod +x appimagetool-x86_64.AppImage
fi

# Create AppImage
./appimagetool-x86_64.AppImage AppDir

echo "AppImage created successfully!"