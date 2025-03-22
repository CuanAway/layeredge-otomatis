#!/bin/bash

# ========================================
#   CuanAway Node Installer
#   GitHub: https://github.com/CuanAway
#   Twitter: https://x.com/testwayyyy
# ========================================

echo "======================================"
echo " 🚀 Selamat datang di CuanAway Node Installer!"
echo " 🌐 GitHub: https://github.com/CuanAway"
echo " 🐦 Twitter: https://x.com/testwayyyy"
echo "======================================"
sleep 2

# Menampilkan logo dari GitHub
LOGO_URL="https://raw.githubusercontent.com/CuanAway/logo/main/96741114.jpg"
echo "🖼  Menampilkan logo..."
curl -o logo.jpg $LOGO_URL
echo "✅ Logo berhasil diunduh!"

# Periksa apakah script dijalankan sebagai root
if [ "$(id -u)" != "0" ]; then
   echo "❌ Harap jalankan script ini sebagai root atau gunakan sudo." 1>&2
   exit 1
fi

# Update dan install dependensi
echo "📥 Mengupdate dan menginstall dependensi..."
apt update && apt upgrade -y
apt install -y git curl build-essential

# Install Go
GO_VERSION="1.21.6"
echo "🔧 Menginstall Go ${GO_VERSION}..."
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
rm -rf /usr/local/go
tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

# Verifikasi instalasi Go
go version

# Clone repositori light-node
echo "📂 Meng-clone repositori light-node..."
git clone https://github.com/CuanAway/light-node.git
cd light-node

# Build light-node
echo "⚙️  Mem-build light-node..."
go mod tidy
go build

# Menjalankan light-node
echo "🚀 Menjalankan light-node..."
./light-node &

# Memberikan informasi kunci publik dan privat
echo "✅ Node Anda telah berhasil berjalan!"
echo "🔑 Simpan kunci privat dan publik Anda untuk menghubungkan CLI node ke dashboard."
