#!/bin/bash

# ========================================
#   CuanAway Node Installer
#   GitHub: https://github.com/CuanAway
#   Twitter: https://x.com/testwayyyy
# ========================================

# Fungsi untuk menampilkan teks dengan warna
print_color() {
    local color=$1
    local text=$2
    echo -e "${color}${text}\e[0m"
}

# Warna untuk teks (sesuai logo: pink cerah untuk "CUANAWAY")
PINK_BRIGHT="\e[38;5;201m"
CYAN="\e[1;36m"
GREEN="\e[1;32m"
RED="\e[1;31m"

# Menampilkan logo ASCII "CUANAWAY" (dari script sebelumnya)
print_color "$PINK_BRIGHT" "   ██████╗██╗   ██╗ █████╗ ███╗   ██╗ █████╗ ██╗    ██╗ █████╗ ██╗   ██╗"
print_color "$PINK_BRIGHT" "  ██╔════╝██║   ██║██╔══██╗████╗  ██║██╔══██╗██║    ██║██╔══██╗╚██╗ ██╔╝"
print_color "$PINK_BRIGHT" "  ██║     ██║   ██║███████║██╔██╗ ██║███████║██║ █╗ ██║███████║ ╚████╔╝ "
print_color "$PINK_BRIGHT" "  ██║     ██║   ██║██╔══██║██║╚██╗██║██╔══██║██║███╗██║██╔══██║  ╚██╔╝  "
print_color "$PINK_BRIGHT" "  ╚██████╗╚██████╔╝██║  ██║██║ ╚████║██║  ██║╚███╔███╔╝██║  ██║   ██║   "
print_color "$PINK_BRIGHT" "   ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚══╝╚══╝╚═╝  ╚═╝   ╚═╝   "
echo "======================================"
print_color "$PINK_BRIGHT" " 🚀 Selamat datang di CuanAway Node Installer!"
echo " 🌐 GitHub: https://github.com/CuanAway"
echo " 🐦 Twitter: https://x.com/testwayyyy"
echo "======================================"
sleep 2

# Periksa apakah script dijalankan sebagai root
if [ "$(id -u)" != "0" ]; then
    print_color "$RED" "❌ Harap jalankan script ini sebagai root atau gunakan sudo."
    exit 1
fi

# Update dan install dependensi
print_color "$CYAN" "📥 Mengupdate dan menginstall dependensi..."
apt update && apt upgrade -y
apt install -y git curl build-essential

# Install Go
GO_VERSION="1.21.6"
print_color "$CYAN" "🔧 Menginstall Go ${GO_VERSION}..."
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
rm -rf /usr/local/go
tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

# Verifikasi instalasi Go
go version
if [ $? -eq 0 ]; then
    print_color "$GREEN" "✅ Go berhasil diinstall: $(go version)"
else
    print_color "$RED" "❌ Gagal menginstall Go."
    exit 1
fi

# Clone repositori light-node
print_color "$CYAN" "📂 Meng-clone repositori light-node..."
git clone https://github.com/CuanAway/light-node.git
cd light-node

# Build light-node
print_color "$CYAN" "⚙️  Mem-build light-node..."
go mod tidy
go build
if [ $? -ne 0 ]; then
    print_color "$RED" "❌ Gagal membuild light-node."
    exit 1
fi

# Membuat systemd service untuk memastikan node berjalan otomatis
print_color "$CYAN" "🔧 Mengatur light-node sebagai service..."
cat << EOF > /etc/systemd/system/light-node.service
[Unit]
Description=CuanAway Light Node
After=network.target

[Service]
ExecStart=$(pwd)/light-node
WorkingDirectory=$(pwd)
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Aktifkan dan jalankan service
systemctl daemon-reload
systemctl enable light-node.service
systemctl start light-node.service

# Periksa status node
sleep 5
if systemctl is-active --quiet light-node.service; then
    print_color "$GREEN" "✅ Light-node berjalan dengan sukses!"
else
    print_color "$RED" "❌ Light-node gagal berjalan. Periksa log dengan: journalctl -u light-node.service"
    exit 1
fi

# Menghasilkan kunci publik dan privat (diasumsikan light-node punya perintah untuk ini)
print_color "$CYAN" "🔑 Menghasilkan kunci publik dan privat..."
# Ganti perintah berikut dengan perintah aktual dari light-node untuk menghasilkan kunci
# Misalnya: ./light-node generate-keys
# Untuk contoh, saya simulasikan outputnya
PUBLIC_KEY="your-public-key-here"
PRIVATE_KEY="your-private-key-here"

# Simpan kunci ke file
echo "Public Key: $PUBLIC_KEY" > keys.txt
echo "Private Key: $PRIVATE_KEY" >> keys.txt
print_color "$GREEN" "✅ Kunci disimpan di $(pwd)/keys.txt"

# Instruksi untuk menghubungkan ke dashboard
print_color "$CYAN" "📊 Menghubungkan CLI ke dashboard..."
print_color "$GREEN" "1. Buka dashboard LayerEdge."
print_color "$GREEN" "2. Masuk ke menu 'CLI-Base Node' dan klik ikon '+'."
print_color "$GREEN" "3. Paste Public Key dari $(pwd)/keys.txt:"
print_color "$PINK_BRIGHT" "   $PUBLIC_KEY"
print_color "$GREEN" "4. Klik 'Link Your Wallet' di dashboard."

# Peringatan jika dashboard tidak terhubung
print_color "$CYAN" "⚠️ Catatan:"
print_color "$CYAN" "Jika dashboard tidak terhubung (pesan 'cli node not started'), periksa:"
print_color "$CYAN" "- Pastikan node berjalan: systemctl status light-node.service"
print_color "$CYAN" "- Dashboard mungkin sedang maintenance (cek pengumuman resmi LayerEdge)."
print_color "$CYAN" "- Jika slot node penuh, coba lagi nanti."

print_color "$PINK_BRIGHT" "🎉 Instalasi selesai! Node Anda siap digunakan."
