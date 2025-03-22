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

tampilkan_teks_warna "$CYAN" "🔄 Merestart layanan light-node..."
systemctl restart light-node.service && tampilkan_teks_warna "$GREEN" "✅ Layanan light-node berhasil direstart" || { tampilkan_teks_warna "$RED" "❌ Gagal merestart light-node"; exit 1; }

tampilkan_teks_warna "$CYAN" "🔄 Merestart layanan risc0-merkle-service..."
systemctl restart risc0-merkle-service.service && tampilkan_teks_warna "$GREEN" "✅ Layanan risc0-merkle-service berhasil direstart" || { tampilkan_teks_warna "$RED" "❌ Gagal merestart risc0-merkle-service"; exit 1; }

tampilkan_teks_warna "$GREEN" "✅ Semua layanan telah direstart."
