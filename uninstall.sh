#!/bin/bash

# Fungsi untuk menampilkan teks dengan warna
tampilkan_teks_warna() {
    local warna=$1
    local teks=$2
    echo -e "${warna}${teks}\e[0m"
}

# Warna untuk teks
CYAN="\e[1;36m"
GREEN="\e[1;32m"
RED="\e[1;31m"

# Periksa apakah script dijalankan sebagai root
if [ "$(id -u)" != "0" ]; then
    tampilkan_teks_warna "$RED" "❌ Script ini harus dijalankan sebagai root atau menggunakan sudo."
    exit 1
fi

tampilkan_teks_warna "$CYAN" "🗑️ Menghentikan dan menonaktifkan layanan..."
systemctl stop light-node.service risc0-merkle-service.service
systemctl disable light-node.service risc0-merkle-service.service

tampilkan_teks_warna "$CYAN" "🗑️ Menghapus file layanan systemd..."
rm -f /etc/systemd/system/light-node.service /etc/systemd/system/risc0-merkle-service.service
systemctl daemon-reload

tampilkan_teks_warna "$CYAN" "🗑️ Menghapus direktori light-node..."
cd /root
rm -rf light-node

tampilkan_teks_warna "$CYAN" "🗑️ Menghapus Go (opsional, uncomment jika diperlukan)..."
# rm -rf /usr/local/go
# sed -i '/export PATH=\$PATH:\/usr/local\/go\/bin/d' /root/.bashrc

tampilkan_teks_warna "$CYAN" "🗑️ Menghapus Rust dan Risc0 (opsional, uncomment jika diperlukan)..."
# rm -rf /root/.cargo /root/.risc0 /root/.rustup
# sed -i '/export PATH=\$PATH:\/root\/\.cargo\/bin:\/root\/\.risc0\/bin/d' /root/.bashrc

tampilkan_teks_warna "$GREEN" "✅ Uninstall selesai! Node LayerEdge telah dihapus."
tampilkan_teks_warna "$CYAN" "Catatan: Go, Rust, dan Risc0 tidak dihapus secara default untuk menghindari gangguan pada sistem lain."
