[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

別に 1 つの言語または別の 1 つの形式からテキスト ファイルに変換します。 次のファイル形式がサポートされています。

| ファイルの形式 | 拡張機能 |
| --- | --- |
| [特性](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| Windows リソース ファイル | `.resw, .resx` |
| [物件リスト](https://en.wikipedia.org/wiki/Property_list) (OSX plist) | `.plist` |
| [PO ファイル](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [XCodeの文字列](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [YAML](http://yaml.org/) | `.yaml` |
| HTML | `.html, .htm, .shtml` |
| XML | `.xml` |
| [値下げ](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| テキストファイル | `.txt` |

次の翻訳 Api は、Translatomatic で使用できます。

- [Google](https://cloud.google.com/translate/)
- [マイクロソフト](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [MyMemory](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

翻訳文字列に保存されたデータベースの再利用されます。

* * *

## インストール

この機能を追加ラインの中から必要なものを選んで使用 `Gemfile`:

`ruby
gem 'translatomatic'
`

そして実行す:

    $ bundle

インストールで自分自身:

    $ gem install translatomatic

* * *

## の使用

この宝石と呼ばれる実行可能ファイルを提供します。 `translatomatic`ます。 、 `translatomatic` コマンドは、いくつかのここに記載されているすべての機能を持ちます。 利用可能なコマンドとオプションに関するヘルプを実行します。

    $ translatomatic help

ヘルプ コマンドが実行します。

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

## セットアップ

利用可能な翻訳サービスとオプションを確認、 `services` コマンド:

    $ translatomatic services

オプションは、コマンドライン、環境変数、または translatomatic の構成ファイルで指定することができます。 Translatomatic を使用してファイルを変更することができます構成の内部 `config` コマンドです。 すべての利用可能な構成設定を一覧表示するには、使用します。

    $ translatomatic config list
    $ translatomatic config describe

オプションは、ユーザー レベルまたはプロジェクト レベルで設定することができます。 詳細については、後述の構成も参照してください。

* * *

## ファイルの翻訳

ファイルを変換するとき `translatomatic` 変換テキストの文章や言葉です。 ファイルが再翻訳された場合、最後の翻訳から変更されている唯一の文は翻訳者に送信され、残りの部分は、ローカル データベースから供給されます。

ドイツ語とフランス語の Google 翻訳を使用して Java のプロパティ ファイルを翻訳。

    $ translatomatic translate file --translator Google strings.properties de,fr

こうした成(上書き) `strings_de.properties` - `strings_fr.properties` 変換のプロパティを実行します。

### 表示文字列からリソースバンドル

読みを表示 `store.description` - `store.name` 物件からの現地リソースファイル、英語、ドイツ、フランス語：

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### 抽出から文字列をソースファイル

ソース ファイルから文字列を抽出するを使用、 `strings` コマンド例。

    $ translatomatic strings file.rb

* * *

## ファイルを変換します。

Translatomatic を使用して、1 つの形式から別のファイルを変換できます。 たとえば、Java に変換する、XCode をプロパティ ファイル文字列ファイル。

    $ translatomatic convert strings.properties Localization.strings

* * *

## 構成

Translatomatic は、ユーザーごとの構成ファイル `$HOME/.translatomatic/config.yml`、および必要に応じて、プロジェクト構成ファイルあたり `$PROJECT_DIR/.translatomatic/config.yml`ます。 、e `translatomatic config set` コマンドは、プロジェクト レベルの構成 translatomatic 構成ファイルを含むプロジェクト内で実行されたときに動作します。tそうでなければユーザー レベルの構成ファイルが変更されます。he `--context` 指定するオプションを使用できます。 `user` または `project` レベルの構成。 構成オプションの有効な値は、環境、ユーザー レベルの構成ファイル、プロジェクト レベルの構成ファイル (存在する場合)、およびコマンド ・ ラインからの読書によって決まります。 最後の値は、以前に読み取られた値よりも優先されます。

### Translatomatic の設定例

設定するのには `google_api_key` ユーザー構成ファイル内で使用します。

    $ translatomatic config set google_api_key value --context user

使用する 1 つまたは複数の翻訳サービスを設定: する

    $ translatomatic config set translator Microsoft,Yandex

二次翻訳者は、最初の選択肢を使用する場合、変換エラーが発生した場合にのみ使用されます。

ターゲットのロケールの既定の一覧を設定: する

    $ translatomatic config set target_locales en,de,es,fr,it

と `target_locales` 設定すると、ファイルはターゲットのロケールを指定することがなく翻訳が可能、 `translate file` コマンドです。

    $ translatomatic translate file resources/strings.properties

現在の構成を表示するには、を実行します。

    $ translatomatic config list

### データベースの構成

デフォルトでは、 `translatomatic` を使用してsqlite3データベース `$HOME/.translatomatic/translatomatic.sqlite3` 店舗の翻訳の文字列です。 翻訳をデータベースに格納するようにインストールされている適切なデータベース アダプターが必要、 `sqlite3` 逸品です。 Translatomatic では、データベース アダプターを自動的にインストールされません。 データベースの構成を作成することによって変更できます、 `database.yml` ファイル `$HOME/.translatomatic/database.yml` のための `production` 環境、例えば

    production:
      adapter: mysql2
      host: db.example.com
      database: translatomatic
      pool: 5
      encoding: utf8
      username: username
      password: password

* * *

## 貢献

バグ報告を引き要請を歓迎GitHubでhttps://github.com/smugglys/translatomaticます。 このプロジェクトなどに対応できるようになっても安全で快適なスペースのための協力者が付着し [執筆規約](http://contributor-covenant.org) 行動規範です。

* * *

## ライセンス

の逸品をご用意してオープンソースの条件の下での [MITライセンス](https://opensource.org/licenses/MIT)ます。

* * *

## 行動規範

皆様との交流のTranslatomaticプロジェクトのcodebases、ラッカー、チャットルームやメーリングリストで入力してください [行動規範](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md)ます。

_Translatomatic 0.1.2 Sat, 06 Jan 2018 13:04:32 +1030 によって作成されました。_
