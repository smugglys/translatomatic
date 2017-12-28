[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

変換テキストファイルから一言語ます。 以下のファイル形式は現在サポートされているのは、:

- [特性](https://en.wikipedia.org/wiki/.properties)
- RESW(Windows資源ファイル)
- [物件リスト](https://en.wikipedia.org/wiki/Property_list) (OSX plist)
- HTML
- XML
- [XCodeの文字列](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html)
- [YAML](http://yaml.org/)
- テキストファイル

翻訳文字列に保存されたデータベースの再利用されます。

## 設置

この機能を追加ラインの中から必要なものを選んで使用 `Gemfile`:

`ruby
gem 'translatomatic'
`

そして実行す:

    $ bundle

インストールで自分自身:

    $ gem install translatomatic

## 用途

のコマンドラインインターフェース翻訳のための機能を `translatomatic`ます。 めに利用可能なオプションは、実行す:

    $ translatomatic help

### 翻訳ファイル

`translatomatic` 変換テキストの文章や言葉です。 場合はファイルを再翻訳の文言変更への翻訳に対しても、それぞれの地域からデータベースです。

るシリコーンコーティング翻訳サービス-オプション:

    $ translatomatic translators

するJavaプロパティファイルをドイツ語、フランス語:

    $ translatomatic translate resources/strings.properties de fr

こうした成(上書き) `strings_de.properties` - `strings_fr.properties`ます。

### 抽出から文字列をソースファイル

抽出から文字列の一部のソースファイルを抽出すコマンドなどの

    $ translatomatic strings file.rb

### 表示文字列からリソースバンドル

読みを表示 `store.description` - `store.name` 物件からの現地リソースファイル、英語、ドイツ、フランス語：

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

## 構成

デフォルトでは、 `translatomatic` を使用してsqlite3データベース `$HOME/.translatomatic/translatomatic.sqlite3` 店舗の翻訳の文字列です。 データベースの変更により作成 `database.yml` ファイル `$HOME/.translatomatic/database.yml` のための `production` 環境、例えば

    production:
      adapter: mysql2
      host: db.example.com
      database: translatomatic
      pool: 5
      encoding: utf8
      username: username
      password: password

## の貢献

バグ報告を引き要請を歓迎GitHubでhttps://github.com/smugglys/translatomaticます。 このプロジェクトなどに対応できるようになっても安全で快適なスペースのための協力者が付着し [執筆規約](http://contributor-covenant.org) 行動規範です。

## ライセンス

の逸品をご用意してオープンソースの条件の下での [MITライセンス](https://opensource.org/licenses/MIT)ます。

## 行動規範

皆様との交流のTranslatomaticプロジェクトのcodebases、ラッカー、チャットルームやメーリングリストで入力してください [行動規範](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md)ます。

_Created by Translatomatic 0.1.0 2017-12-29 00:38_
