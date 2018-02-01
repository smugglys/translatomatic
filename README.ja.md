[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# 翻訳者

テキストファイルをある言語から別の言語に、ある形式から別の形式に翻訳します。 現在サポートされているファイル形式は次のとおりです。

| ファイルの形式 | 拡張機能 |
| --- | --- |
| [プロパティ](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| Windows リソース ファイル | `.resw, .resx` |
| [プロパティの一覧](https://en.wikipedia.org/wiki/Property_list) （OSX plist） | `.plist` |
| [PO ファイル](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [XCode の文字列](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [YAML](http://yaml.org/) | `.yaml` |
| 字幕 | `.srt, .ass, .ssa` |
| HTML | `.html, .htm, .shtml` |
| XML | `.xml` |
| [値下げ](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| テキスト ファイル | `.txt` |
| CSV ファイル | `.csv` |

次の翻訳プロバイダーは、Translatomatic で使用できます。

- [Google](https://cloud.google.com/translate/)
- [マイクロソフト](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [ヤンデックス](https://tech.yandex.com/translate/)
- [私の思い出](https://mymemory.translated.net/doc/)
- [強く](http://www.frengly.com/api)

翻訳された文字列をデータベースに保存して再利用します。

* * *

## インストール

この行をアプリケーションに追加する `Gemfile`：

`ruby
gem 'translatomatic'
`

実行します。

    $ bundle

または自分でそれをインストールします。

    $ gem install translatomatic

* * *

## の使用

この宝石は、 `translatomatic`。 ザ `translatomatic` コマンドにはいくつかの機能がありますが、そのすべてがここに記載されているわけではありません。 使用可能なコマンドとオプションのヘルプについては、次のコマンドを実行してください。

    $ translatomatic help

ヘルプ コマンドが実行します。

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

## セットアップ

使用可能な翻訳プロバイダとオプションが `providers` コマンド：

    $ translatomatic providers

オプションは、コマンドライン、環境変数、または翻訳の設定ファイルで指定できます。 構成ファイルは、translatomaticの内部 `config` コマンド。 使用可能なすべての構成設定を一覧表示するには、以下を使用します。

    $ translatomatic config list
    $ translatomatic config describe

オプションは、ユーザーレベルまたはプロジェクトレベルで設定できます。 詳細については、以下の設定セクションも参照してください。

* * *

## ファイルの翻訳

ファイルを翻訳するときは、 `translatomatic` 一度に1つの文または句を翻訳します。 ファイルが再翻訳されると、最後の翻訳後に変更された文のみが翻訳プロバイダに送られ、残りはローカルデータベースから供給されます。

ドイツ語とフランス語 Google プロバイダーを使用して Java プロパティ ファイルを翻訳。

    $ translatomatic translate file --provider Google strings.properties de,fr

これにより、 `strings_de.properties` そして `strings_fr.properties` 翻訳されたプロパティで。

### リソース バンドルから文字列を表示します。

を読み、表示するには `store.description` そして `store.name` 英語、ドイツ語、フランス語のローカルリソースファイルのプロパティ：

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### ソース ファイルから文字列を抽出

ソースファイルから文字列を抽出するには、 `strings` コマンド、例えば

    $ translatomatic strings file.rb

* * *

## ファイルを変換します。

Translatomaticを使用して、ファイルをあるフォーマットから別のフォーマットに変換することができます。 たとえば、JavaプロパティファイルをXCode文字列ファイルに変換するには、次のようにします。

    $ translatomatic convert strings.properties Localization.strings

* * *

## 構成

設定を読み書きするには、 `config get` そして `config set` コマンド。 Translatomaticは、ユーザ設定ファイルを `$HOME/.translatomatic/config.yml`、オプションでプロジェクトごとの構成ファイル `$PROJECT_DIR/.translatomatic/config.yml`。

ザ `--user` そして `--project` オプションを使用すると、コマンドに読み取りまたは書き込みを指示することができます。 `user` または `project` 構成。

構成設定は、環境変数、ユーザー構成ファイル、プロジェクト構成ファイル（存在する場合）、およびコマンド行から読み取られます。 最後に見つかった値は、先に読み取った値よりも優先されます。

コンフィグレーションに `config set` 新しい値は、翻訳構成ファイルを含むプロジェクト内で実行された場合はプロジェクト構成ファイルに書き込まれ、プロジェクト構成ファイルが存在しない場合はユーザー構成ファイルに書き込まれます。

### Translatomatic の設定例

設定するには `google_api_key` ユーザー構成ファイル内で、次のように使用します。

    $ translatomatic config set google_api_key value --user

使用する 1 つまたは複数の翻訳サービスを設定: する

    $ translatomatic config set provider Microsoft,Yandex

ターゲットのロケールの既定の一覧を設定: する

    $ translatomatic config set target_locales en,de,es,fr,it

と `target_locales` 設定すると、ターゲットロケールを指定せずにファイルを翻訳することができます。 `translate file` コマンド。

    $ translatomatic translate file resources/strings.properties

現在の構成を表示するには、を実行します。

    $ translatomatic config list

### データベースの構成

デフォルトでは、 `translatomatic` のsqlite3データベースを使用 `$HOME/.translatomatic/translatomatic.sqlite3` 翻訳された文字列を格納します。 データベース構成は、 `database.yml` 下のファイル `$HOME/.translatomatic/database.yml` のために `production` 環境、例えば

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

## 貢献

バグ報告とプルリクエストは、GitHub（https://github.com/smugglys/translatomatic）で歓迎します。 このプロジェクトは、共同作業のための安全で歓迎すべき空間であり、寄稿者は [貢献者契約](http://contributor-covenant.org) 行動規範。

* * *

## ライセンス

この宝石は、オープンソースとしての [MIT ライセンス](https://opensource.org/licenses/MIT)。

* * *

## 行動規範

Translatomaticプロジェクトのコードベース、課題トラッカー、チャットルーム、メーリングリストと対話するすべての人は、 [行動規範](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md)。

_によって作成された Translatomatic 0.1.3 Thu, 01 Feb 2018 21:35:41 +1030 https://github.com/smugglys/translatomatic_
