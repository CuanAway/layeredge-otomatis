#!/bin/bash

# ========================================
#   Penginstal Node CuanAway LayerEdge
#   GitHub: https://github.com/CuanAway/layeredge-otomatis
# ========================================

# Fungsi untuk menampilkan teks dengan warna
tampilkan_teks_warna() {
    local warna=$1
    local teks=$2
    echo -e "${warna}${teks}\e[0m"
}

# Warna untuk teks
PINK_BRIGHT="\e[38;5;201m"
CYAN="\e[1;36m"
GREEN="\e[1;32m"
RED="\e[1;31m"

# Menampilkan logo ASCII "CUANAWAY"
tampilkan_teks_warna "$PINK_BRIGHT" "   ██████╗██╗   ██╗ █████╗ ███╗   ██╗ █████╗ ██╗    ██╗ █████╗ ██╗   ██╗"
tampilkan_teks_warna "$PINK_BRIGHT" "  ██╔════╝██║   ██║██╔══██╗████╗  ██║██╔══██╗██║    ██║██╔══██╗╚██╗ ██╔╝"
tampilkan_teks_warna "$PINK_BRIGHT" "  ██║     ██║   ██║███████║██╔██╗ ██║███████║██║ █╗ ██║███████║ ╚████╔╝ "
tampilkan_teks_warna "$PINK_BRIGHT" "  ██║     ██║   ██║██╔══██║██║╚██╗██║██╔══██║██║███╗██║██╔══██║  ╚██╔╝  "
tampilkan_teks_warna "$PINK_BRIGHT" "  ╚██████╗╚██████╔╝██║  ██║██║ ╚████║██║  ██║╚███╔███╔╝██║  ██║   ██║   "
tampilkan_teks_warna "$PINK_BRIGHT" "   ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝   ╚═╝   "
echo "======================================"
tampilkan_teks_warna "$PINK_BRIGHT" " 🚀 Selamat Datang di Penginstal Node CuanAway LayerEdge!"
echo " 🌐 GitHub: https://github.com/CuanAway/layeredge-otomatis"
echo "======================================"
sleep 2

# Periksa apakah script dijalankan sebagai root
if [ "$(id -u)" != "0" ]; then
    tampilkan_teks_warna "$RED" "❌ Script ini harus dijalankan sebagai root atau menggunakan sudo."
    exit 1
fi

# Update dan instal dependensi dasar
tampilkan_teks_warna "$CYAN" "📥 Memperbarui dan menginstal dependensi dasar..."
apt update && apt upgrade -y
apt install -y git curl build-essential libssl-dev pkg-config xz-utils cmake ninja-build

# Instal Go
GO_VERSION="1.21.6"
GO_FILE="go${GO_VERSION}.linux-amd64.tar.gz"
tampilkan_teks_warna "$CYAN" "🔧 Menginstal Go versi ${GO_VERSION}..."
if [ -f "$GO_FILE" ]; then
    tampilkan_teks_warna "$GREEN" "✅ File $GO_FILE sudah ada, melewati pengunduhan..."
else
    tampilkan_teks_warna "$CYAN" "📥 Mengunduh Go versi ${GO_VERSION}..."
    wget https://go.dev/dl/$GO_FILE || { tampilkan_teks_warna "$RED" "❌ Gagal mengunduh Go."; exit 1; }
fi
rm -rf /usr/local/go
tar -C /usr/local -xzf $GO_FILE
export PATH=$PATH:/usr/local/go/bin
echo 'export PATH=$PATH:/usr/local/go/bin' >> /root/.bashrc
go version && tampilkan_teks_warna "$GREEN" "✅ Go berhasil diinstal: $(go version)" || { tampilkan_teks_warna "$RED" "❌ Gagal menginstal Go."; exit 1; }

# Instal Rust (gunakan nightly untuk RISC Zero)
tampilkan_teks_warna "$CYAN" "🔧 Menginstal Rust (nightly untuk RISC Zero)..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly
source "$HOME/.cargo/env"
rustc --version && tampilkan_teks_warna "$GREEN" "✅ Rust berhasil diinstal: $(rustc --version)" || { tampilkan_teks_warna "$RED" "❌ Gagal menginstal Rust."; exit 1; }
rustup target add riscv32im-risc0-zkvm-elf --toolchain nightly

# Instal Risc0 toolchain
tampilkan_teks_warna "$CYAN" "🔧 Menginstal perangkat Risc0..."
export HOME=/root
mkdir -p $HOME/.cargo/bin $HOME/.risc0/bin
chmod -R 755 $HOME/.cargo $HOME/.risc0
export PATH=$PATH:$HOME/.cargo/bin:$HOME/.risc0/bin
echo 'export PATH=$PATH:/usr/local/go/bin:/root/.cargo/bin:/root/.risc0/bin' >> /root/.bashrc
source /root/.bashrc
curl -L https://risczero.com/install | bash
rzup install cargo-risczero
cargo-risczero --help > /dev/null 2>&1 && tampilkan_teks_warna "$GREEN" "✅ Perangkat Risc0 berhasil diinstal" || { tampilkan_teks_warna "$RED" "❌ Gagal menginstal cargo-risczero."; exit 1; }
rzup install

# Clone repositori light-node
tampilkan_teks_warna "$CYAN" "📂 Mengunduh repositori light-node..."
[ -d "light-node" ] && tampilkan_teks_warna "$GREEN" "✅ Direktori light-node sudah ada..." || git clone https://github.com/CuanAway/light-node.git
cd light-node

# Periksa dan buat file .env
tampilkan_teks_warna "$CYAN" "🔍 Memeriksa file .env untuk konfigurasi light-node..."
if [ ! -f ".env" ]; then
    tampilkan_teks_warna "$RED" "⚠️ File .env tidak ditemukan. Membuat template .env..."
    cat << EOF > .env
GRPC_URL=grpc.testnet.layeredge.io:9090
CONTRACT_ADDR=cosmos1ufs3tlq4umljk0qfe8k5ya0x6hpavn897u2cnf9k0en9jr7qarqqt56709
ZK_PROVER_URL=http://127.0.0.1:3001
API_REQUEST_TIMEOUT=100
POINTS_API=http://127.0.0.1:8080
PRIVATE_KEY=
EOF
    tampilkan_teks_warna "$CYAN" "📝 File .env telah dibuat di $(pwd)/.env"
fi

# Build host (risc0-merkle-service)
tampilkan_teks_warna "$CYAN" "⚙️ Membangun host (risc0-merkle-service)..."
cd risc0-merkle-service
cargo clean
tampilkan_teks_warna "$CYAN" "🔧 Membangun host dengan cargo (mode rilis)..."
cargo build --release --bin host > risc0-merkle-build.log 2>&1 || { tampilkan_teks_warna "$RED" "❌ Gagal membangun host. Lihat risc0-merkle-build.log"; cat risc0-merkle-build.log; exit 1; }
BINARY_PATH="$(pwd)/target/release/host"
[ -f "$BINARY_PATH" ] && chmod +x "$BINARY_PATH" && tampilkan_teks_warna "$GREEN" "✅ Berhasil membangun host" || { tampilkan_teks_warna "$RED" "❌ Biner $BINARY_PATH tidak ditemukan."; exit 1; }

# Tes host (risc0-merkle-service)
tampilkan_teks_warna "$CYAN" "🚀 Menjalankan host untuk tes..."
# Pastikan port 3001 bebas
tampilkan_teks_warna "$CYAN" "🔍 Memeriksa port 3001..."
PORT_CHECK=$(netstat -tulnp | grep 3001)
if [ -n "$PORT_CHECK" ]; then
    tampilkan_teks_warna "$RED" "⚠️ Port 3001 sudah digunakan. Menghentikan proses yang ada..."
    PID=$(netstat -tulnp | grep 3001 | awk '{print $7}' | cut -d'/' -f1)
    sudo kill -9 $PID
    sleep 2
    if netstat -tulnp | grep 3001 > /dev/null; then
        tampilkan_teks_warna "$RED" "❌ Gagal membebaskan port 3001. Hentikan proses secara manual."
        exit 1
    else
        tampilkan_teks_warna "$GREEN" "✅ Port 3001 berhasil dibebaskan."
    fi
fi
"$BINARY_PATH" > risc0-merkle-run.log 2>&1 &
RISC0_PID=$!
sleep 5
if ps -p $RISC0_PID > /dev/null; then
    tampilkan_teks_warna "$GREEN" "✅ Host berjalan dengan PID $RISC0_PID"
    kill -15 $RISC0_PID
    sleep 2
    pkill -9 -f r0vm  # Hentikan proses r0vm sisa
else
    tampilkan_teks_warna "$RED" "❌ Gagal menjalankan host. Lihat risc0-merkle-run.log"
    cat risc0-merkle-run.log
    exit 1
fi

# Build light-node
cd ..
tampilkan_teks_warna "$CYAN" "⚙️ Membangun light-node..."
go mod tidy
go build || { tampilkan_teks_warna "$RED" "❌ Gagal membangun light-node."; exit 1; }
[ -f "light-node" ] && chmod +x light-node || { tampilkan_teks_warna "$RED" "❌ Biner light-node tidak ditemukan."; exit 1; }

# Tes light-node
tampilkan_teks_warna "$CYAN" "🚀 Menjalankan light-node untuk tes..."
./light-node > light-node.log 2>&1 &
LIGHT_NODE_PID=$!
sleep 5
if ps -p $LIGHT_NODE_PID > /dev/null; then
    tampilkan_teks_warna "$GREEN" "✅ Light-node berjalan dengan PID $LIGHT_NODE_PID"
    kill -15 $LIGHT_NODE_PID
else
    tampilkan_teks_warna "$RED" "❌ Gagal menjalankan light-node. Lihat light-node.log"
    cat light-node.log
    exit 1
fi

# Menghasilkan kunci publik dan privat
tampilkan_teks_warna "$CYAN" "🔑 Menghasilkan kunci publik dan privat untuk CLI node..."
# Pastikan risc0-merkle-service berjalan untuk ZK Prover
tampilkan_teks_warna "$CYAN" "🚀 Memulai risc0-merkle-service untuk menghasilkan kunci..."
# Pastikan port 3001 bebas lagi
PORT_CHECK=$(netstat -tulnp | grep 3001)
if [ -n "$PORT_CHECK" ]; then
    tampilkan_teks_warna "$RED" "⚠️ Port 3001 sudah digunakan. Menghentikan proses yang ada..."
    PID=$(netstat -tulnp | grep 3001 | awk '{print $7}' | cut -d'/' -f1)
    sudo kill -9 $PID
    sleep 2
    if netstat -tulnp | grep 3001 > /dev/null; then
        tampilkan_teks_warna "$RED" "❌ Gagal membebaskan port 3001. Hentikan proses secara manual."
        exit 1
    else
        tampilkan_teks_warna "$GREEN" "✅ Port 3001 berhasil dibebaskan."
    fi
fi
"$BINARY_PATH" > risc0-merkle-run.log 2>&1 &
RISC0_PID=$!
sleep 5
if ! ps -p $RISC0_PID > /dev/null; then
    tampilkan_teks_warna "$RED" "❌ risc0-merkle-service gagal berjalan. Lihat risc0-merkle-run.log"
    cat risc0-merkle-run.log
    exit 1
fi

# Jalankan light-node untuk menghasilkan kunci
./light-node > keygen.log 2>&1 &
KEYGEN_PID=$!
sleep 60  # Beri waktu lebih lama untuk memastikan kunci dihasilkan
kill -15 $KEYGEN_PID
kill -15 $RISC0_PID
sleep 2
pkill -9 -f r0vm  # Hentikan proses r0vm sisa

# Ekstrak kunci dari log
PUBLIC_KEY=$(grep -oP "Compressed Public Key: \K.*" keygen.log || echo "Gagal menemukan kunci publik")
PRIVATE_KEY=$(grep -oP "Private Key: \K.*" keygen.log || echo "Gagal menemukan kunci privat")
if [ "$PUBLIC_KEY" != "Gagal menemukan kunci publik" ] && [ "$PRIVATE_KEY" != "Gagal menemukan kunci privat" ]; then
    echo "Kunci Publik: $PUBLIC_KEY" > keys.txt
    echo "Kunci Privat: $PRIVATE_KEY" >> keys.txt
    tampilkan_teks_warna "$GREEN" "✅ Kunci berhasil dibuat dan disimpan di $(pwd)/keys.txt"
    # Perbarui PRIVATE_KEY di .env
    sed -i "s/PRIVATE_KEY=.*/PRIVATE_KEY=$PRIVATE_KEY/" .env
    tampilkan_teks_warna "$GREEN" "✅ File .env diperbarui dengan kunci privat"
else
    tampilkan_teks_warna "$RED" "❌ Gagal menghasilkan kunci. Lihat keygen.log untuk detail."
    cat keygen.log
    if [ "$PUBLIC_KEY" != "Gagal menemukan kunci publik" ]; then
        echo "Kunci Publik: $PUBLIC_KEY" > keys.txt
        tampilkan_teks_warna "$GREEN" "✅ Kunci publik ditemukan dan disimpan di $(pwd)/keys.txt"
        tampilkan_teks_warna "$CYAN" "⚠️ Kunci privat tidak ditemukan. Ikuti langkah berikut untuk menghasilkan secara manual:"
        tampilkan_teks_warna "$CYAN" "1. Jalankan: openssl ecparam -name secp256k1 -genkey -noout -out privkey.pem"
        tampilkan_teks_warna "$CYAN" "2. Ekstrak kunci privat: openssl ec -in privkey.pem -text -noout | grep -A 3 'priv:' | tail -n 3 | tr -d ' \n:'"
        tampilkan_teks_warna "$CYAN" "3. Masukkan kunci privat ke .env pada PRIVATE_KEY="
    else
        tampilkan_teks_warna "$CYAN" "⚠️ Tidak ada kunci yang ditemukan. Anda perlu membuat kunci secara manual:"
        tampilkan_teks_warna "$CYAN" "1. Jalankan: openssl ecparam -name secp256k1 -genkey -noout -out privkey.pem"
        tampilkan_teks_warna "$CYAN" "2. Ekstrak kunci privat: openssl ec -in privkey.pem -text -noout | grep -A 3 'priv:' | tail -n 3 | tr -d ' \n:'"
        tampilkan_teks_warna "$CYAN" "3. Masukkan kunci privat ke .env pada PRIVATE_KEY="
    fi
fi

# Tambahkan pengecekan flag --ci-mode untuk GitHub Actions
CI_MODE=false
if [[ "$1" == "--ci-mode" ]]; then
    CI_MODE=true
fi

# Membuat systemd service
if [ "$CI_MODE" = false ]; then
    tampilkan_teks_warna "$CYAN" "🔧 Mengatur light-node sebagai layanan..."
    cat << EOF > /etc/systemd/system/light-node.service
[Unit]
Description=Node Ringan CuanAway LayerEdge
After=network.target

[Service]
ExecStart=$(pwd)/light-node
WorkingDirectory=$(pwd)
Restart=always
User=root
Environment="PATH=$PATH:/usr/local/go/bin:/root/.cargo/bin:/root/.risc0/bin"
EnvironmentFile=$(pwd)/.env

[Install]
WantedBy=multi-user.target
EOF

    tampilkan_teks_warna "$CYAN" "🔧 Mengatur host (risc0-merkle-service) sebagai layanan..."
    cat << EOF > /etc/systemd/system/risc0-merkle-service.service
[Unit]
Description=Layanan Risc0 Merkle untuk Node Ringan CuanAway
After=network.target

[Service]
ExecStart=$BINARY_PATH
WorkingDirectory=$(pwd)/risc0-merkle-service
Restart=always
User=root
Environment="PATH=$PATH:/usr/local/go/bin:/root/.cargo/bin:/root/.risc0/bin"
EnvironmentFile=$(pwd)/.env

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable risc0-merkle-service.service
    systemctl start risc0-merkle-service.service
    sleep 5
    systemctl is-active --quiet risc0-merkle-service.service && tampilkan_teks_warna "$GREEN" "✅ Host (risc0-merkle-service) berjalan dengan sukses!" || { tampilkan_teks_warna "$RED" "❌ Host (risc0-merkle-service) gagal berjalan. Periksa log dengan: journalctl -u risc0-merkle-service.service"; exit 1; }

    systemctl enable light-node.service
    systemctl start light-node.service
    sleep 5
    systemctl is-active --quiet light-node.service && tampilkan_teks_warna "$GREEN" "✅ Light-node berjalan dengan sukses!" || { tampilkan_teks_warna "$RED" "❌ Light-node gagal berjalan. Periksa log dengan: journalctl -u light-node.service"; exit 1; }
else
    tampilkan_teks_warna "$CYAN" "⚠️ Mode CI: Melewati langkah systemctl karena tidak didukung di GitHub Actions."
fi

# Instruksi untuk menghubungkan ke dashboard
tampilkan_teks_warna "$CYAN" "📊 Menghubungkan CLI ke dashboard..."
tampilkan_teks_warna "$GREEN" "1. Buka dashboard LayerEdge."
tampilkan_teks_warna "$GREEN" "2. Masuk ke menu 'CLI-Base Node' dan klik ikon '+'."
tampilkan_teks_warna "$GREEN" "3. Salin Kunci Publik dari $(pwd)/keys.txt:"
tampilkan_teks_warna "$PINK_BRIGHT" "   $PUBLIC_KEY"
tampilkan_teks_warna "$GREEN" "4. Klik 'Hubungkan Dompet Anda' di dashboard."

# Peringatan jika dashboard tidak terhubung
tampilkan_teks_warna "$CYAN" "⚠️ Catatan:"
tampilkan_teks_warna "$CYAN" "Jika dashboard tidak terhubung (pesan 'node cli belum dimulai'), periksa:"
tampilkan_teks_warna "$CYAN" "- Pastikan node berjalan: systemctl status light-node.service"
tampilkan_teks_warna "$CYAN" "- Pastikan host (risc0-merkle-service) berjalan: systemctl status risc0-merkle-service.service"
tampilkan_teks_warna "$CYAN" "- Dashboard mungkin sedang dalam pemeliharaan (cek pengumuman resmi LayerEdge)."
tampilkan_teks_warna "$CYAN" "- Jika slot node penuh, coba lagi nanti."

tampilkan_teks_warna "$PINK_BRIGHT" "🎉 Instalasi selesai! Node Anda siap digunakan."
