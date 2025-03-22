```markdown
# CuanAway LayerEdge Otomatis

Script otomatis untuk menginstal, mengelola, dan menghapus node LayerEdge dari CuanAway di sistem berbasis Ubuntu/Debian. Dibuat untuk mempermudah pengguna dalam menjalankan node dengan konfigurasi yang stabil dan terintegrasi ke dashboard LayerEdge.

## Fitur
- **Instalasi Otomatis**: Menginstal dependensi (Go, Rust, Risc0), `light-node`, dan `risc0-merkle-service`.
- **Layanan Systemd**: Menjalankan node dan prover sebagai layanan untuk uptime maksimal.
- **Pembuatan Kunci**: Menghasilkan kunci publik untuk CLI dan opsi manual untuk kunci privat.
- **Manajemen Port**: Menangani konflik port 3001 secara otomatis.
- **Skrip Utilitas**: Termasuk `stop.sh`, `restart.sh`, dan `uninstall.sh` untuk pengelolaan node.
- **CI GitHub Actions**: Otomatisasi pengujian dan penyimpanan kunci sebagai artifact.
- **Antarmuka Ramah**: Logo ASCII "CUANAWAY" dengan teks berwarna untuk pengalaman visual.

## Prasyarat
- **OS**: Ubuntu/Debian (disarankan Ubuntu 20.04 atau lebih baru).
- **Akses Root**: Jalankan semua skrip dengan `sudo`.
- **Spesifikasi Minimum**: 4 vCPU, 8GB RAM, 50GB SSD (berdasarkan VPS Anda).
- **Koneksi Internet**: Stabil untuk mengunduh dependensi dan sinkronisasi node.

## Struktur Repositori
- `install.sh`: Skrip utama untuk instalasi.
- `stop.sh`: Menghentikan layanan node.
- `restart.sh`: Merestart layanan node.
- `uninstall.sh`: Menghapus node dan layanan.
- `.github/workflows/ci.yml`: Konfigurasi CI untuk GitHub Actions.
- `README.md`: Dokumentasi ini.
```

## Tutorial Instalasi

### Langkah 1: Clone Repositori
Unduh kode dari GitHub ke VPS Anda:
```bash
git clone https://github.com/CuanAway/layeredge-otomatis.git
cd layeredge-otomatis
```


### Langkah 2: Beri Izin Eksekusi
Buat semua skrip dapat dieksekusi:
```bash
chmod +x install.sh stop.sh restart.sh uninstall.sh
```

### Langkah 3: Jalankan Instalasi
Jalankan skrip instalasi dengan hak root:
```bash
sudo ./install.sh
```
Skrip akan:
- Menginstal Go (v1.21.6), Rust (nightly), dan Risc0 toolchain.
- Clone dan build light-node dari https://github.com/CuanAway/light-node.
- Build risc0-merkle-service.
- Membuat file .env dengan konfigurasi default.
- Menghasilkan kunci publik (dan mencoba kunci privat).
- Mengatur light-node dan risc0-merkle-service sebagai layanan systemd.

Output sukses akan menunjukkan kunci publik di `/root/layeredge-otomatis/light-node/keys.txt`.

### Langkah 4: Verifikasi Kunci
Periksa kunci yang dihasilkan:
```bash
cat /root/layeredge-otomatis/light-node/keys.txt
```
Contoh isi:
```
Kunci Publik: 02b51febfc6f06bdd91ff01c237430cf72d54b644aac186018b138cfbd65856bd0
```
Jika kunci privat tidak ada, lihat bagian Menangani Kunci Privat.

### Langkah 5: Hubungkan ke Dashboard
- Buka Dashboard LayerEdge di browser.
- Masuk ke menu CLI-Base Node > Klik ikon +.
- Salin Kunci Publik dari `keys.txt`.
- Klik Hubungkan Dompet Anda untuk mengaitkan node.

### Langkah 6: Verifikasi Layanan
Pastikan layanan berjalan:
```bash
systemctl status light-node.service
systemctl status risc0-merkle-service.service
```
Status harus `active (running)`.

## Pengelolaan Node

### Menghentikan Node
Hentikan layanan sementara:
```bash
sudo ./stop.sh
```
Output akan mengkonfirmasi penghentian kedua layanan.

### Merestart Node
Restart layanan untuk penyegaran:
```bash
sudo ./restart.sh
```
Berguna jika node tidak responsif atau setelah update `.env`.

### Menghapus Node
Hapus node sepenuhnya:
```bash
sudo ./uninstall.sh
```
Menghentikan layanan, menghapus file systemd, dan direktori `light-node`. Go dan Rust tetap terinstal (edit skrip untuk menghapusnya jika perlu).

## Menangani Kunci Privat
Jika `keys.txt` hanya berisi kunci publik:

### Cek Log:
```bash
cat /root/layeredge-otomatis/light-node/keygen.log
```
Cari "Private Key". Jika tidak ada, lanjutkan ke langkah berikutnya.

### Buat Kunci Privat Manual:
```bash
openssl ecparam -name secp256k1 -genkey -noout -out privkey.pem
openssl ec -in privkey.pem -text -noout | grep -A 3 "priv:" | tail -n 3 | tr -d " \n:"
```
Contoh output: `1234abcd... (64 karakter hex)`.

### Update `.env`:
```bash
nano /root/layeredge-otomatis/light-node/.env
```
Ganti baris `PRIVATE_KEY=` menjadi:
```env
PRIVATE_KEY=1234abcd...
```

### Restart Layanan:
```bash
sudo ./restart.sh
```

## Troubleshooting

### Port 3001 Sudah Digunakan
Jika instalasi gagal dengan pesan "Address already in use":

### Cek Proses:
```bash
sudo netstat -tulnp | grep 3001
```
Catat PID (contoh: `12345`).

### Hentikan Proses:
```bash
sudo kill -9 12345
```

### Jalankan Ulang:
```bash
sudo ./install.sh
```

### Layanan Gagal Berjalan
Jika salah satu layanan tidak aktif:

### Cek Status:
```bash
systemctl status light-node.service
systemctl status risc0-merkle-service.service
```

### Lihat Log:
```bash
journalctl -u light-node.service
journalctl -u risc0-merkle-service.service
```

### Restart:
```bash
sudo ./restart.sh
```

### Dashboard Tidak Terhubung
Jika pesan "node cli belum dimulai" muncul:

- Verifikasi layanan aktif (lihat di atas).
- Cek `.env` untuk konfigurasi yang benar.
- Pastikan port 3001 tidak diblokir oleh firewall:
```bash
sudo ufw allow 3001
```
- Periksa pengumuman resmi LayerEdge untuk pemeliharaan.

### Kunci Tidak Dihasilkan
Jika `keys.txt` kosong:

### Cek Log:
```bash
cat /root/layeredge-otomatis/light-node/keygen.log
cat /root/layeredge-otomatis/light-node/risc0-merkle-service/risc0-merkle-run.log
```

### Jalankan Manual:
```bash
cd /root/layeredge-otomatis/light-node
./risc0-merkle-service/target/release/host &
./light-node
```
Biarkan berjalan 1-2 menit, lalu hentikan dengan `Ctrl+C`.

## GitHub Actions
- Setiap push/pull request ke branch `main` memicu CI.
- Kunci disimpan sebagai artifact (`node-keys`) di tab Actions.

## File Penting
- `/root/layeredge-otomatis/light-node/.env`: Konfigurasi node.
- `/root/layeredge-otomatis/light-node/keys.txt`: Kunci publik (dan privat jika ada).
- `/root/layeredge-otomatis/light-node/keygen.log`: Log pembuatan kunci.
- `/root/layeredge-otomatis/light-node/risc0-merkle-service/risc0-merkle-run.log`: Log `risc0-merkle-service`.

## Kontribusi
- Fork repositori ini.
- Buat branch baru untuk perubahan Anda.
- Ajukan pull request dengan deskripsi jelas.

## Lisensi
MIT License

## Catatan Penting
- Skrip diuji pada Ubuntu dengan 4 vCPU, 8GB RAM.
- Kunci privat mungkin tidak dihasilkan otomatis oleh light-node. Gunakan metode manual jika perlu.
- Pastikan port 3001 bebas untuk komunikasi lokal antara light-node dan risc0-merkle-service.

Terima kasih telah menggunakan CuanAway LayerEdge Otomatis! Jika ada masalah, buka issue di GitHub.

---

### Langkah untuk Update Repositori

1. **Perbarui `README.md` di VPS**:
   ```bash
   cd /root/layeredge-otomatis
   nano README.md  # Salin dan tempel isi di atas
   ```

2. **Pastikan Semua File Terbaru**:
   - Gunakan `install.sh` dan `stop.sh` dari jawaban sebelumnya.
   - Jika `restart.sh` dan `uninstall.sh` belum diperbarui, beri tahu saya untuk menyediakannya.

3. **Commit dan Push**:
   ```bash
   git add install.sh stop.sh restart.sh uninstall.sh .github/workflows/ci.yml README.md
   git commit -m "Update README dengan tutorial lengkap dan terperinci"
   git push origin master
   ```

4. **Verifikasi di GitHub**:
   - Buka [https://github.com/CuanAway/layeredge-otomatis](https://github.com/CuanAway/layeredge-otomatis).
   - Pastikan `README.md` tampil dengan benar dan semua file ada.
