[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Menterjemahkan teks fail dari satu bahasa yang lain, atau dari satu format yang lain. Format fail berikut disokong buat masa ini:

| Format fail | Sambungan |
| --- | --- |
| [Sifat](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| Fail sumber Windows | `.resw, .resx` |
| [Harta senarai](https://en.wikipedia.org/wiki/Property_list) (SELEPAS plist) | `.plist` |
| [Fail PO](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [Dan diganti dengan tali](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [YAML](http://yaml.org/) | `.yaml` |
| Sari kata | `.srt, .ass, .ssa` |
| HTML | `.html, .htm, .shtml` |
| FAIL | `.xml` |
| [Markdown](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| Fail teks | `.txt` |
| Fail CSV | `.csv` |

Terjemahan berikut api boleh digunakan dengan Translatomatic:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/provider/providerapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [MyMemory](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

Diterjemahkan tali disimpan dalam pengkalan data dan semula.

* * *

## Pemasangan

Masukkan baris ini untuk anda permohonan `Gemfile`:

`ruby
gem 'translatomatic'
`

Dan kemudian melaksanakan:

    $ bundle

Atau memasang sendiri sebagai:

    $ gem install translatomatic

* * *

## Penggunaan

Permata ini menyediakan boleh laku yang dipanggil `translatomatic`. Dalam `translatomatic` arahan mempunyai beberapa fungsi, tidak semua yang dihuraikan di sini. Untuk bantuan tentang perintah tersedia dan opsyen, melaksanakan:

    $ translatomatic help

Dan untuk bantuan tentang arahan, melaksanakan:

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

## Persediaan

Menyemak Perkhidmatan penterjemahan tersedia dan dengan itu `services` perintah:

    $ translatomatic services

Pilihan boleh ditetapkan pada baris arahan, dalam pembolehubah persekitaran, atau dalam fail konfigurasi di translatomatic. Konfigurasi fail boleh diubahsuai menggunakan translatomatic di Dalaman `config` perintah. Untuk menyenaraikan semua tetapan tatarajah tersedia, gunakan:

    $ translatomatic config list
    $ translatomatic config describe

Pilihan boleh ditetapkan pada paras pengguna atau peringkat projek. Lihat juga Seksyen konfigurasi di bawah untuk maklumat lanjut.

* * *

## Menterjemahkan fail

Apabila menterjemahkan fail, `translatomatic` diterjemahkan teks satu ayat atau frasa pada suatu waktu. Jika fail terjemahan semula, ayat sahaja yang telah berubah sejak lepas terjemahan dihantar kepada penterjemah, dan selebihnya diperolehi dari pangkalan data tempatan.

Untuk menterjemahkan fail sifat Java untuk Jerman dan Perancis yang menggunakan Google penterjemah:

    $ translatomatic translate file --provider Google strings.properties de,fr

Ini akan membuat (atau tindih) `strings_de.properties` dan `strings_fr.properties` dengan sifat-sifat yang diterjemahkan.

### Memaparkan tali dari sumber ikatan

Untuk membaca dan memaparkan `store.description` dan `store.name` sifat dari sumber lokal fail dalam bahasa inggris, bahasa jerman, dan perancis:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### Mengekstrak tali dari sumber fail

Untuk mengekstrak rentetan daripada fail sumber, gunakan dalam `strings` arahan, misalnya

    $ translatomatic strings file.rb

* * *

## Menukar fail

Translatomatic boleh digunakan untuk menukar fail dari satu format yang lain. Contohnya, untuk menukar Java yang sifat fail untuk XCode satu tali fail:

    $ translatomatic convert strings.properties Localization.strings

* * *

## Konfigurasi

Translatomatic mempunyai fail konfigurasi setiap pengguna di `$HOME/.translatomatic/config.yml`, dan yang satu fail konfigurasi projek `$PROJECT_DIR/.translatomatic/config.yml`. Dalame `translatomatic config set` Perintah beroperasi pada projek peringkat konfigurasi apabila dilaksanakan dalam sebuah projek yang mengandungi fail tatarajah translatomatic.e. Jika tidak fail tatarajah peringkat pengguna ditukar. The `--context` pilihan boleh digunakan untuk menentukan `user` atau `project` peringkat konfigurasi. Nilai berkesan opsyen konfigurasi ditentukan melalui pembacaan dari alam sekitar, pengguna peringkat Konfigurasi fail, fail konfigurasi tahap projek (jika ada), dan dari baris perintah. Nilai lepas yang mendapati keutamaan berbanding nilai membaca lebih awal.

### Contoh-contoh tatarajah Translatomatic

Untuk menetapkan `google_api_key` dalam fail konfigurasi pengguna, gunakan:

    $ translatomatic config set google_api_key value --context user

Untuk menetapkan satu atau lebih perkhidmatan penterjemahan untuk digunakan:

    $ translatomatic config set provider Microsoft,Yandex

Penterjemah menengah hanya boleh digunakan jika satu ralat penterjemahan berlaku bila menggunakan pilihan pertama.

Untuk menetapkan senarai sasaran locales lalai:

    $ translatomatic config set target_locales en,de,es,fr,it

Dengan `target_locales` ditetapkan, fail boleh diterjemahkan tanpa menentukan sasaran locales di dalam `translate file` perintah.

    $ translatomatic translate file resources/strings.properties

Untuk memaparkan konfigurasi semasa, melaksanakan

    $ translatomatic config list

### Pangkalan data konfigurasi

Oleh lalai, `translatomatic` menggunakan sqlite3 dalam `$HOME/.translatomatic/translatomatic.sqlite3` untuk menyimpan tali diterjemahkan. Untuk menyimpan terjemahan dalam pangkalan data, anda harus mempunyai penyesuai pangkalan data yang sesuai dipasang, seperti yang `sqlite3` permata. Translatomatic memasang penyesuai pangkalan data secara automatik ini. Pangkalan data konfigurasi boleh ditukar dengan mencipta satu `database.yml` file yang di bawah `$HOME/.translatomatic/database.yml` untuk itu `production` persekitaran, contohnya.

    production:
      adapter: mysql2
      host: db.example.com
      database: translatomatic
      pool: 5
      encoding: utf8
      username: username
      password: password

* * *

## Menyumbang

Laporan Bug dan tarik permintaan selamat datang pada Orang yang di https://github.com/smugglys/translatomatic. Projek ini dimaksudkan untuk menjadi aman, menyambut ruang untuk kerjasama, dan penyumbang diharapkan untuk mematuhi [Penyumbang Perjanjian](http://contributor-covenant.org) code of conduct.

* * *

## Lesen

Permata yang ada sebagai sumber terbuka di bawah segi [MIT Lesen](https://opensource.org/licenses/MIT).

* * *

## Tatakelakuan

Semua orang berinteraksi dengan Translatomatic projek codebases, isu trackers, chat bilik dan senarai mel adalah diharapkan untuk mengikuti [Kod Amalan](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Dicipta oleh Translatomatic 0.1.2 Sat, 06 Jan 2018 22:56:25 +1030_
