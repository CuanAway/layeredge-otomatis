# CuanAway LayerEdge Otomatis

Script otomatis untuk menginstall, mengelola, dan menghapus node LayerEdge dari CuanAway.

## Fitur
- Instalasi otomatis dependensi, Go, Rust, Risc0, dan light-node.
- Menjalankan node sebagai systemd service.
- Menghasilkan kunci publik dan privat untuk menghubungkan CLI ke dashboard.
- Skrip tambahan untuk menghentikan, merestart, dan meng-uninstall node.
- Warna teks yang menarik dengan logo ASCII "CUANAWAY".
- Otomatisasi CI menggunakan GitHub Actions.

## Prasyarat
- Sistem operasi berbasis Ubuntu/Debian.
- Akses root atau sudo.
- Koneksi internet.

## Cara Menggunakan

### Instalasi
1. Clone repositori ini:
   ```bash
   git clone https://github.com/CuanAway/layeredge-otomatis.git
   cd layeredge-otomatis
