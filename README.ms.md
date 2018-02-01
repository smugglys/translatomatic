[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Menterjemah fail teks dari satu bahasa ke bahasa yang lain, atau dari satu format ke yang lain. Format fail berikut kini disokong:

| Format fail | Sambungan |
| --- | --- |
| [Sifat-sifat](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| Fail sumber Windows | `.resw, .resx` |
| [Senarai Hartanah](https://en.wikipedia.org/wiki/Property_list) (OSX plist) | `.plist` |
| [Fail PO](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [Tali XCode](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [YAML](http://yaml.org/) | `.yaml` |
| Sari kata | `.srt, .ass, .ssa` |
| HTML | `.html, .htm, .shtml` |
| XML | `.xml` |
| [Kemerosotan](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| Fail teks | `.txt` |
| Fail CSV | `.csv` |

Pembekal terjemahan berikut boleh digunakan dengan Translatomatic:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [Ingatan saya](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

Rentetan terjemahan akan disimpan dalam pangkalan data dan diguna semula.

* * *

## Pemasangan

Tambahkan baris ini ke aplikasi anda `Gemfile`:

`ruby
gem 'translatomatic'
`

Dan kemudian melaksanakan:

    $ bundle

Atau memasang sendiri sebagai:

    $ gem install translatomatic

* * *

## Penggunaan

Permata ini menyediakan panggilan yang boleh dipanggil `translatomatic`. Dalam `translatomatic` Perintah mempunyai beberapa fungsi, tidak semua didokumentasikan di sini. Untuk bantuan arahan dan pilihan yang ada, laksanakan:

    $ translatomatic help

Dan untuk bantuan tentang arahan, melaksanakan:

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

## Persediaan

Semak penyedia dan opsyen terjemahan yang tersedia dengan `providers` arahan:

    $ translatomatic providers

Pilihan boleh ditentukan pada baris perintah, dalam pembolehubah persekitaran, atau dalam fail konfigurasi translatomatik. Fail konfigurasi boleh diubah suai menggunakan dalaman translatomatik `config` perintah. Untuk menyenaraikan semua tetapan konfigurasi yang ada, gunakan:

    $ translatomatic config list
    $ translatomatic config describe

Pilihan boleh ditetapkan pada tahap pengguna atau tahap projek. Lihat juga bahagian Konfigurasi di bawah untuk maklumat lanjut.

* * *

## Menterjemahkan fail

Semasa menterjemah fail, `translatomatic` menterjemahkan teks satu kalimat atau frasa pada satu masa. Sekiranya fail diterjemahkan semula, hanya kalimat yang telah berubah sejak penterjemahan terakhir dihantar kepada penyedia terjemahan, dan selebihnya diperoleh daripada pangkalan data setempat.

Untuk menterjemahkan fail sifat Java untuk Jerman dan Perancis yang menggunakan pembekal Google:

    $ translatomatic translate file --provider Google strings.properties de,fr

Ini akan mencipta (atau menulis semula) `strings_de.properties` dan `strings_fr.properties` dengan sifat yang diterjemahkan.

### Memaparkan rentetan dari pakej sumber

Untuk membaca dan memaparkan `store.description` dan `store.name` sifat dari fail sumber tempatan dalam bahasa Inggeris, Jerman, dan Perancis:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### Meraih rentetan daripada fail sumber

Untuk mengekstrak rentetan daripada fail sumber, gunakan `strings` perintah, contohnya

    $ translatomatic strings file.rb

* * *

## Menukar fail

Translatomatic boleh digunakan untuk menukar fail dari satu format ke format lain. Sebagai contoh, untuk menukar fail sifat Java ke fail rentetan XCode:

    $ translatomatic convert strings.properties Localization.strings

* * *

## Konfigurasi

Tetapan tatarajah boleh dibaca dan ditulis dengan menggunakan `config get` dan `config set` arahan. Translatomatic menggunakan fail konfigurasi pengguna pada `$HOME/.translatomatic/config.yml`, dan secara pilihan satu fail konfigurasi projek `$PROJECT_DIR/.translatomatic/config.yml`.

Dalam `--user` dan `--project` pilihan boleh digunakan untuk memberitahu arahan untuk membaca atau menulis kepada `user` atau `project` konfigurasi.

Pengaturan konfigurasi dibaca dari pembolehubah persekitaran, fail konfigurasi pengguna, fail konfigurasi projek (jika ada), dan dari baris arahan. Nilai terakhir yang dijumpai lebih tinggi daripada nilai yang dibaca sebelum ini.

Apabila menulis kepada konfigurasi dengan `config set` Perintah, nilai baru ditulis pada fail konfigurasi projek apabila dilaksanakan dalam projek yang mengandungi fail konfigurasi translatomatic, atau fail konfigurasi pengguna jika tidak ada fail konfigurasi projek.

### Contoh-contoh tatarajah Translatomatic

Untuk menetapkan `google_api_key` dalam fail konfigurasi pengguna, gunakan:

    $ translatomatic config set google_api_key value --user

Untuk menetapkan satu atau lebih perkhidmatan penterjemahan untuk digunakan:

    $ translatomatic config set provider Microsoft,Yandex

Untuk menetapkan senarai sasaran locales lalai:

    $ translatomatic config set target_locales en,de,es,fr,it

Dengan `target_locales` tetapkan, fail boleh diterjemahkan tanpa menentukan sasaran lokasi dalam `translate file` perintah.

    $ translatomatic translate file resources/strings.properties

Untuk memaparkan konfigurasi semasa, melaksanakan:

    $ translatomatic config list

### Pangkalan data konfigurasi

Secara lalai, `translatomatic` menggunakan pangkalan data sqlite3 dalam `$HOME/.translatomatic/translatomatic.sqlite3` untuk menyimpan tali yang diterjemahkan. Konfigurasi pangkalan data boleh diubah dengan membuat a `database.yml` fail di bawah `$HOME/.translatomatic/database.yml` untuk `production` persekitaran, contohnya

    production:
      adapter: mysql2
      host: db.example.com
      database: translatomatic
      pool: 5
      encoding: utf8
      collation: utf8_bin
      username: username
      password: password

* * *

## Menyumbang

Laporan pepijat dan permintaan tarik dialu-alukan di GitHub di https://github.com/smugglys/translatomatic. Projek ini bertujuan untuk menjadi ruang yang selamat, mesra untuk kerjasama, dan penyumbang dijangka mematuhi [Perjanjian sebagai penyumbang](http://contributor-covenant.org) kod tatalaku.

* * *

## Lesen

Permata ini tersedia sebagai sumber terbuka di bawah terma [Lesen MIT](https://opensource.org/licenses/MIT).

* * *

## Tatakelakuan

Semua orang berinteraksi dengan kod bahasa projek Translatomatic, mengeluarkan pelacak, bilik sembang dan senarai mel diharapkan akan mengikuti [Kod Amalan](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Dicipta oleh Translatomatic 0.1.3 Thu, 01 Feb 2018 21:35:41 +1030 https://github.com/smugglys/translatomatic_
