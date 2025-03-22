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

tampilkan_teks_warna "$CYAN" "⏹️ Menghentikan layanan light-node..."
if systemctl stop light-node.service; then
    tampilkan_teks_warna "$GREEN" "✅ Layanan light-node berhasil dihentikan"
else
    tampilkan_teks_warna "$RED" "⚠️ Gagal menghentikan light-node atau layanan tidak ada"
fi

tampilkan_teks_warna "$CYAN" "⏹️ Menghentikan layanan risc0-merkle-service..."
if systemctl stop risc0-merkle-service.service; then
    tampilkan_teks_warna "$GREEN" "✅ Layanan risc0-merkle-service berhasil dihentikan"
else
    tampilkan_teks_warna "$RED" "⚠️ Gagal menghentikan risc0-merkle-service atau layanan tidak ada"
fi

tampilkan_teks_warna "$GREEN" "✅ Proses penghentian selesai."
