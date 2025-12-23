# venyuk_mobile

Nama-nama anggota kelompok 
-Anderson Tirza Liman 
-Bintoro Nata Wijaya 
-Favian Muhammad Rasyad Reswara 
-Muhammad Fattan Azzaka 
-Clairine Christabel Lim 
-Cyrillo Praditya Soeharto

-Deskripsi aplikasi (cerita aplikasi yang diajukan serta kebermanfaatannya) Venyuk adalah aplikasi yang memberikan jasa untuk para penggunanya agar dapat menyewa venue/lapangan untuk jenis-jenis olahraga yang bervariasi. Tidak hanya itu Venyuk juga memiliki fitur untuk membeli perlengkapan untuk mendukung aktivitas olahraga pengguna. Kemudian pengguna dapat melakukan sparing dengan mencari lawan dengan fitur yang disediakan.Jika pengguna tidak memiliki teman untuk bermain Venyuk juga menyediakan fitur untuk "main bareng" dengan join venue yang ada dan masih kekurangan orang.Terakhir Venyuk menyediakan blog sebagai portal informasi untuk pemberitahuan terkini mengenai dunia olahraga,e-sport, dan public figure yang berhubungan dengan kegiatan olahraga(contohnya tentang acara bahkan voli, tepuk bulu, dan semacamnya).

-Daftar Modul yang akan diimplementasikan modul:

sewa lapangan (Andy)
toko alat(Ello)
main bareng (clairine)
sparing (rasyad)
promo (zaka)
blog (Bintoro)

-Role atau peran pengguna beserta deskripsinya (karena bisa saja lebih dari satu jenis pengguna yang mengakses aplikasi) 
-Admin(Dapat menambahkan Venue,menghapus venue,menambahkan blog,dll) -User(Dapat mengakses fitur-fitur yang telah disediakan tetapi tidak dapat melakukan perubahan jadi hanya bisa booking dan membaca blog) -User belum login(Cuman bisa liat-liat jadi kalo mau pesen, beli, sparring, ikutan main, bikin post, dll, itu harus login/daftar)

Alur pengintegrasiannya sendiri adalah pada pekan pertama fitur yang pertama kali di integrasi adalah Login dan Register yang merupakan fondasi untuk keseluruhan modul,kemudian di peka kedua fitur untuk menampilkan list booking venue,lalu di minggu ketiga baru modul-modul sisanya diintegrasikan. Dan di minggu terakhir digunakan untuk melakukan perbaikan bug-bug yang kemungkinan muncul selama proses uji coba.

Alur & penjelasan penggunaan modul pada aplikasi adalah sebagai berikut:
- User akan landing pertama kali pada sebuah halaman landing page, dengan beberapa tampilan mengenai Venue yang dapat disewakan (gambar-gambar venue) beserta dengan keterangan tambahan aplikasi (identitas, motto aplikasi, dll)
- Agar dapat menggunakan fitur, user dapat melakukan login dengan menekan tombol login pada halaman/drawer, bisa juga melakukan register apabila belum memiliki akun. Saat user melakukan autentikasi, aplikasi akan terintegrasi dengan Django sehingga data username dan password akan tersimpan di database.
- Setelah user berhasil login, fitur-fitur pada aplikasi dapat digunakan, seperti: Sewa Venue, Berbelanja di Shop, Match Up (main bareng), Versus (bertanding melawan orang/tim lain), menggunakan promo, serta membaca artikel/blog yang tersedia.
- Operasi CRUD sederhana dapat dilakukan user pada fitur: Sewa Venue (Create-View-Edit-Cancel Booking), Match- Up (Create-View-Edit-Delete Match Up), Versus (Create-View-Edit-Delete Versus Match). Kemudin untuk fitur Belanja di Shop, bisa dilakukan operasi View/Read Product dan confirm purchase; Operasi Create, Update, dan Delete hanya dapat dilakukan oleh admin. Untuk fitur Article/Blog, hanya admin yang dapat Create-Update-Delete article, sedangkan user biasa hanya bisa read. Untuk fitur promo, user biasa dapat melakukan read, sedangkan untuk fitur Create-Update-Delete, hanya admin yang bisa melakukannya.
- Ada juga penggunaan cookies untuk prosesi login-logout. Apabila user sudah selesai menggunakan aplikasi, user dapat menekan tombol log out untuk mengakhiri sesi.

Link Figma:
https://www.figma.com/design/tWsB5Iaigw3EHNq5Rle7Fw/Untitled?node-id=0-1&t=jrxblqVwznSRYAqy-1
