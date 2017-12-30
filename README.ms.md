[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Diterjemahkan teks fail-fail dari satu bahasa yang lain. Berikut file format disokong:

- [Sifat](https://en.wikipedia.org/wiki/.properties)
- RESW (Tingkap sumber file)
- [Harta senarai](https://en.wikipedia.org/wiki/Property_list) (SELEPAS plist)
- HTML
- FAIL
- [Dan diganti dengan tali](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html)
- [YAML](http://yaml.org/)
- Fail teks

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

Baris perintah muka untuk terjemahan fungsi `translatomatic`. Untuk membantu pada pilihan yang ada, melaksanakan:

    $ translatomatic help

### Menterjemahkan fail

`translatomatic` diterjemahkan teks satu ayat atau frasa pada suatu waktu. Jika fail adalah re-diterjemahkan, hanya ayat yang telah berubah dihantar ke penterjemah, dan sisanya adalah sumber dari pangkalan data tempatan.

Untuk senarai yang ada perkhidmatan terjemahan dan pilihan:

    $ translatomatic translators

Untuk menterjemahkan Jawa sifat file untuk jerman dan perancis:

    $ translatomatic translate resources/strings.properties de fr

Ini akan membuat (atau tindih) `strings_de.properties` dan `strings_fr.properties`.

### Mengekstrak tali dari sumber fail

Untuk mendapatkan tali dari beberapa sumber fail, gunakan mengeluarkan perintah, contohnya.

    $ translatomatic strings file.rb

### Memaparkan tali dari sumber ikatan

Untuk membaca dan memaparkan `store.description` dan `store.name` sifat dari sumber lokal fail dalam bahasa inggris, bahasa jerman, dan perancis:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

## Konfigurasi

Oleh lalai, `translatomatic` menggunakan sqlite3 dalam `$HOME/.translatomatic/translatomatic.sqlite3` untuk menyimpan tali diterjemahkan. Pangkalan data bisa diubah oleh mewujudkan `database.yml` file yang di bawah `$HOME/.translatomatic/database.yml` untuk itu `production` persekitaran, contohnya.

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

## Code of Conduct

Semua orang berinteraksi dengan Translatomatic projek codebases, isu trackers, chat bilik dan senarai mel adalah diharapkan untuk mengikuti [code of conduct](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Created by Translatomatic 0.1.1 Sat, 30 Dec 2017 22:53:47 +1030_
