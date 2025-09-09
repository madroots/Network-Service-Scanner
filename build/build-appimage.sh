#!/bin/bash

# AppImage build script for NSS GUI

set -e

# Create build directory
mkdir -p AppDir/usr/bin
mkdir -p AppDir/usr/lib
mkdir -p AppDir/usr/share/applications
mkdir -p AppDir/usr/share/icons/hicolor/256x256/apps

# Download and extract Python AppImage
echo "Downloading Python AppImage..."
wget -O python.AppImage "https://github.com/niess/python-appimage/releases/download/python3.9/python3.9.23-cp39-cp39-manylinux2014_x86_64.AppImage"
chmod +x python.AppImage
./python.AppImage --appimage-extract >/dev/null 2>&1

# Copy Python files
cp -r squashfs-root/usr/bin/* AppDir/usr/bin/
cp -r squashfs-root/usr/lib AppDir/usr/
cp -r squashfs-root/usr/share AppDir/usr/ || echo "No share directory to copy"
cp -r squashfs-root/opt AppDir/ || echo "No opt directory to copy"
rm -f AppDir/AppRun

# Copy application files
cp -r main.py ui core AppDir/usr/bin/
cp -r assets AppDir/usr/bin/

# Create launcher script
echo '#!/bin/bash' > AppDir/usr/bin/nss-gui
echo 'DIR="$(dirname "$0")"' >> AppDir/usr/bin/nss-gui
echo '"$DIR/python3.9" "$DIR/main.py" "$@"' >> AppDir/usr/bin/nss-gui
chmod 755 AppDir/usr/bin/nss-gui

# Create desktop entry
cat > AppDir/usr/share/applications/nss-gui.desktop << EOF
[Desktop Entry]
Type=Application
Name=Network Service Scanner
Comment=Scan for open ports on your network
Exec=nss-gui
Icon=nss-gui
Terminal=false
Categories=Network;Security;
EOF

# Copy desktop entry to root of AppDir for AppImage
cp AppDir/usr/share/applications/nss-gui.desktop AppDir/

# Copy icon
if [ -f "assets/nss-gui.svg" ]; then
  cp assets/nss-gui.svg AppDir/nss-gui.svg
  cp assets/nss-gui.svg AppDir/usr/share/icons/hicolor/256x256/apps/nss-gui.svg
fi

# Create AppRun script
cat > AppDir/AppRun << 'EOF'
#!/bin/bash
HERE="$(dirname "$(readlink -f "$0")"
exec "$HERE/usr/bin/nss-gui" "$@"
EOF

chmod 755 AppDir/AppRun

# Download AppImageTool if not present
if [ ! -f appimagetool ]; then
    wget -O appimagetool "https://github.com/AppImage/appimagetool/releases/download/1.9.0/appimagetool-x86_64.AppImage"
    chmod +x appimagetool
fi

# Create AppImage
ARCH=x86_64 ./appimagetool AppDir

# Rename AppImage
if [ -f "Network_Service_Scanner-x86_64.AppImage" ]; then
  mv Network_Service_Scanner-x86_64.AppImage Network-Service-Scanner-x86_64.AppImage
elif ls Network_Service_Scanner*.AppImage 1> /dev/null 2>&1; then
  mv Network_Service_Scanner*.AppImage Network-Service-Scanner-x86_64.AppImage
elif ls *.AppImage 1> /dev/null 2>&1; then
  mv *.AppImage Network-Service-Scanner-x86_64.AppImage
fi

if [ ! -f "Network-Service-Scanner-x86_64.AppImage" ]; then
  echo "Error: AppImage was not created successfully"
  ls -la *.AppImage 2>/dev/null || echo "No AppImage files found"
  exit 1
fi

chmod +x Network-Service-Scanner-x86_64.AppImage

echo "AppImage created successfully!"