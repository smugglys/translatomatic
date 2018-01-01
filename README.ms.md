[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Diterjemahkan teks fail-fail dari satu bahasa yang lain. Berikut file format disokong:

- [Sifat](https://en.wikipedia.org/wiki/.properties)
- RESW (Tingkap sumber file)
- [Harta senarai](https://en.wikipedia.org/wiki/Property_list) (SELEPAS plist)
- HTML
- FAIL
- [Markdown](https://en.wikipedia.org/wiki/Markdown)
- [Dan diganti dengan tali](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html)
- [YAML](http://yaml.org/)
- Fail teks

Terjemahan berikut api boleh digunakan dengan Translatomatic:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [MyMemory](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

Diterjemahkan tali disimpan dalam pengkalan data dan semula.

## Pemasangan

Masukkan baris ini untuk anda permohonan `Gemfile`:

`ruby
gem 'translatomatic'
`

Dan kemudian melaksanakan:

    $ bundle

Atau memasang sendiri sebagai:

    $ gem install translatomatic

## Penggunaan

Permata ini menyediakan boleh laku yang dipanggil `translatomatic`. Dalam `translatomatic` arahan mempunyai beberapa fungsi, tidak semua yang dihuraikan di sini. Untuk bantuan tentang perintah tersedia dan opsyen, melaksanakan:

    $ translatomatic help

Dan untuk bantuan tentang arahan, melaksanakan:

    $ translatomatic translate help
    $ translatomatic translate help file

## Persediaan

Menyemak Perkhidmatan penterjemahan tersedia dan dengan itu `services` perintah:

    $ translatomatic services

Pilihan boleh ditetapkan pada baris arahan, dalam pembolehubah persekitaran, atau dalam fail konfigurasi di translatomatic. Fail konfigurasi boleh diubahsuai menggunakan translatomatic di Dalaman `config` perintah. Untuk menyenaraikan semua tetapan tatarajah tersedia, gunakan:

    $ translatomatic config list
    $ translatomatic config describe

Lihat juga Seksyen konfigurasi di bawah untuk maklumat lanjut.

## Menterjemahkan fail

Apabila menterjemahkan fail, `translatomatic` diterjemahkan teks satu ayat atau frasa pada suatu waktu. Jika fail terjemahan semula, ayat sahaja yang telah berubah sejak lepas terjemahan dihantar kepada penterjemah, dan selebihnya diperolehi dari pangkalan data tempatan.

Untuk menterjemahkan fail sifat Java untuk Jerman dan Perancis yang menggunakan Google penterjemah:

    $ translatomatic translate file --translator Google strings.properties de,fr

Ini akan membuat (atau tindih) `strings_de.properties` dan `strings_fr.properties` dengan sifat-sifat yang diterjemahkan.

### Memaparkan tali dari sumber ikatan

Untuk membaca dan memaparkan `store.description` dan `store.name` sifat dari sumber lokal fail dalam bahasa inggris, bahasa jerman, dan perancis:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### Mengekstrak tali dari sumber fail

Untuk mengekstrak rentetan dari sesetengah fail sumber, gunakan dalam `strings` arahan, misalnya

    $ translatomatic strings file.rb

## Konfigurasi

### Contoh-contoh tatarajah Translatomatic

Untuk menetapkan satu atau lebih perkhidmatan penterjemahan untuk digunakan:

    $ translatomatic config set translator Microsoft,Yandex

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

## Menyumbang

Laporan Bug dan tarik permintaan selamat datang pada Orang yang di https://github.com/smugglys/translatomatic. Projek ini dimaksudkan untuk menjadi aman, menyambut ruang untuk kerjasama, dan penyumbang diharapkan untuk mematuhi [Penyumbang Perjanjian](http://contributor-covenant.org) code of conduct.

## Lesen

Permata yang ada sebagai sumber terbuka di bawah segi [MIT Lesen](https://opensource.org/licenses/MIT).

## Kod Amalan

Semua orang berinteraksi dengan Translatomatic projek codebases, isu trackers, chat bilik dan senarai mel adalah diharapkan untuk mengikuti [Kod Amalan](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Dicipta oleh Translatomatic 0.1.1 Mon, 01 Jan 2018 21:36:22 +1030_
