#!/usr/bin/env bash
# 
# Automatizált Snap7 telepítés Ubuntu Serverre
# Davenardella Snap7

set -e

echo "Frissítés és build eszközök telepítése..."
sudo apt update
sudo apt install -y build-essential git python3 python3-pip python3-dev

WORKDIR=$(mktemp -d)
cd "$WORKDIR"

echo "Snap7 letöltése..."
git clone https://github.com/davenardella/snap7.git
cd snap7/build/linux

# --- Makefile natív fordító beállítása
echo "Makefile natív fordításra állítása..."
# Ellenőrizzük, hogy van-e CXX sor, és átírjuk g++-ra
if grep -q '^CXX' Makefile; then
    sed -i 's|^CXX.*|CXX = g++|' Makefile
else
    echo "CXX = g++" >> Makefile
fi

echo "Fordítás make segítségével..."
make clean
make

ARCH=$(uname -m)
echo "Telepítés rendszerkönyvtárba..."
if [[ "$ARCH" == "x86_64" ]]; then
    sudo cp ../../bin/x86_64-linux/libsnap7.so /usr/lib/
elif [[ "$ARCH" == "aarch64" ]]; then
    sudo cp ../../bin/arm64-linux/libsnap7.so /usr/lib/
else
    echo "Ismeretlen architektúra: $ARCH"
    echo "Másold kézzel a libsnap7.so-t a megfelelő helyre."
fi
sudo ldconfig

echo "python-snap7 telepítése pip-pel..."
pip install python-snap7


echo "Telepítés kész, teszteljük..."
python3 - <<'EOF'
import snap7
print("python-snap7 import OK, verzió:", getattr(snap7, "__version__", "ismeretlen"))
EOF

cd ~
rm -rf "$WORKDIR"
echo "----------------------------------------------------"
echo "Snap7 telepítés befejezve!"
