# Venyuk Mobile 🏸🏀⚽

[![Build Status](https://app.bitrise.io/app/e23bc240-0243-4708-94f7-fedf4c2c7ffc/status.svg?token=WgX9jDtYPVcT92Yzfq-Vog&branch=main)](https://app.bitrise.io/app/e23bc240-0243-4708-94f7-fedf4c2c7ffc)

## 📱 Tentang Venyuk

**Venyuk** adalah aplikasi layanan penyewaan venue olahraga (Sport Venue Booking) yang memudahkan pengguna untuk mencari dan menyewa lapangan olahraga. Tidak hanya itu, Venyuk hadir sebagai _one-stop solution_ bagi pecinta olahraga dengan menyediakan fitur toko peralatan olahraga, pencarian lawan tanding (sparing), hingga komunitas main bareng.

Aplikasi ini juga dilengkapi dengan portal berita (Blog) untuk menyajikan informasi terkini seputar dunia olahraga, e-sport, dan public figure.

### 📥 Unduh Aplikasi
Dapatkan versi terbaru aplikasi Venyuk di sini:
[**Download APK**](https://app.bitrise.io/app/e23bc240-0243-4708-94f7-fedf4c2c7ffc/installable-artifacts/2ca6947c2036bd59/public-install-page/ebc0410f5d3368a699f2d0c1681c7ec5)

---

## 👥 Tim Pengembang & Modul

Berikut adalah daftar anggota kelompok beserta modul yang diimplementasikan:

| Nama Anggota | Modul / Fitur | Deskripsi Singkat |
| :--- | :--- | :--- |
| **Anderson Tirza Liman** | Sewa Lapangan | Fitur utama untuk melihat daftar venue dan melakukan booking. |
| **Cyrillo Praditya Soeharto** | Toko Alat (Shop) | E-commerce mini untuk membeli perlengkapan olahraga. |
| **Clairine Christabel Lim** | Main Bareng | Fitur untuk join venue yang kekurangan pemain. |
| **Favian Muhammad Rasyad R.** | Sparing | Mencari lawan tanding (tim vs tim atau perorangan). |
| **Muhammad Fattan Azzaka** | Promo | Manajemen kode promo dan diskon untuk user. |
| **Bintoro Nata Wijaya** | Blog | Portal informasi dan berita olahraga terkini. |

---

## 🔑 Role Pengguna

Aplikasi ini memiliki 3 jenis role dengan hak akses yang berbeda:

1.  **Guest (User Belum Login)**
    * Hanya dapat melihat-lihat daftar venue, produk, dan blog (Read Only).
    * Harus melakukan registrasi/login untuk melakukan transaksi atau interaksi.
2.  **Authenticated User (User Login)**
    * Dapat melakukan booking venue, membeli alat, membuat jadwal sparing, dan join main bareng.
    * Memiliki akses penuh ke fitur CRUD user (kecuali fitur admin).
3.  **Admin / Superuser**
    * Memiliki hak akses penuh untuk manajemen konten.
    * Dapat menambahkan/menghapus Venue, membuat postingan Blog, update stok Toko, dan manajemen Promo.

---

## 🛠️ Alur Integrasi & Pengembangan

Proyek ini dikembangkan dengan tahapan sebagai berikut:

* **Minggu 1:** Integrasi fitur **Autentikasi (Login & Register)** sebagai fondasi utama.
* **Minggu 2:** Integrasi fitur **List Booking Venue**.
* **Minggu 3:** Integrasi seluruh modul sisa (Shop, Sparing, Main Bareng, Promo, Blog).
* **Minggu 4:** _Bug Fixing_, _Quality Assurance_, dan penyempurnaan UI/UX.

---

## 📖 Panduan Pengguna (User Flow)

1.  **Landing Page**
    * Saat pertama kali membuka aplikasi, user akan disambut halaman Landing Page yang menampilkan highlight venue dan informasi aplikasi.
2.  **Autentikasi**
    * User menekan tombol login pada Drawer atau halaman utama.
    * Data akun akan tersimpan di database Django.
    * _Cookies_ digunakan untuk manajemen sesi login/logout.
3.  **Penggunaan Fitur**
    * **Sewa Venue:** User dapat melakukan _Create, View, Edit,_ dan _Cancel_ booking.
    * **Shop:** User melihat katalog dan membeli barang. (Admin mengelola stok barang).
    * **Match Up & Versus:** User dapat membuat room untuk main bareng atau mencari lawan tanding.
    * **Blog & Promo:** User membaca artikel dan menggunakan promo yang tersedia.
4.  **Logout**
    * User menekan tombol logout untuk mengakhiri sesi dan kembali menjadi Guest.

---

## 🎨 Desain Antarmuka

Desain UI/UX aplikasi ini dapat dilihat melalui Figma berikut:
[**Lihat Desain Figma**](https://www.figma.com/design/tWsB5Iaigw3EHNq5Rle7Fw/Untitled?node-id=0-1&t=jrxblqVwznSRYAqy-1)