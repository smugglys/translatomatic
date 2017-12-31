[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

変換テキストファイルから一言語ます。 以下のファイル形式 は現在サポートされているのは、

- [特性](https://en.wikipedia.org/wiki/.properties)
- RESW(Windows資源ファイル)
- [物件リスト](https://en.wikipedia.org/wiki/Property_list) (OSX plist)
- HTML
- XML
- [値下げ](https://en.wikipedia.org/wiki/Markdown)
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

この宝石と呼ばれる実行可能ファイルを提供します。 `translatomatic`ます、he `translatomatic` コマンドは、いくつかのここに記載されているすべての機能を持ちます。 利用可能なコマンドとオプションに関するヘルプを実行します。

    $ translatomatic help

ヘルプ サブコマンドが実行します。

    $ translatomatic translate help
    $ translatomatic translate help file

### 翻訳ファイル

ファイルを変換するとき `translatomatic` 変換テキストの文章や言葉です。 If a file is re-translated, only sファイルが再翻訳された場合、最後の翻訳から変更されている唯一の文は翻訳者に送信され、残りの部分は、ローカル データベースから供給されます。

るシリコーンコーティング翻訳サービス-オプション:

    $ translatomatic list

するJavaプロパティファイルをドイツ語、フランス語:

    $ translatomatic translate file resources/strings.properties de,fr

こうした成(上書き) `strings_de.properties` - `strings_fr.properties`ます。

### 表示文字列からリソースバンドル

読みを表示 `store.description` - `store.name` 物件からの現地リソースファイル、英語、ドイツ、フランス語：

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### 抽出から文字列をソースファイル

抽出から文字列の一部のソースファイルを抽出すコマンドなどの

    $ translatomatic strings file.rb

## 構成

### Translatomatic 構成ファイル

多くのコマンド ライン オプションは、Translatomatic を使用して構成することができますの内部 `config` コマンドです。 たとえば、ターゲット翻訳ロケールのデフォルト リストを設定するを実行します。

    $ translatomatic config set target_locales en,de,es,fr,it

と `target_locales` 設定すると、ファイルはターゲットのロケールを指定することがなく翻訳が可能、 `translate file` コマンドです。

    $ translatomatic translate file resources/strings.properties

現在の構成を表示するには、を実行します。

    $ translatomatic config list

### データベースの構成

デフォルトでは、 `translatomatic` を使用してsqlite3データベース `$HOME/.translatomatic/translatomatic.sqlite3` 店舗の翻訳の文字列です。 To store transla翻訳をデータベースに格納するようにインストールされている適切なデータベース アダプターが必要、`sqlite3` 逸品です。 Translatomatic では、データベース アダプターを自動的にインストールされません。 データベースの構成を作成することによって変更できます、 `database.yml` ファイル `$HOME/.translatomatic/database.yml` のための `production` 環境、例えば

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

_Created by Translatomatic 0.1.1 Sun, 31 Dec 2017 17:27:46 +1030_
