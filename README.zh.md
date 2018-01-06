[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

将文本文件从一种语言转换为另一种, 或从一种格式翻译成另一种。 当前支持以下文件格式:

| 文件格式 | 扩展 |
| --- | --- |
| [性能](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| Windows 资源文件 | `.resw, .resx` |
| [酒店名单](https://en.wikipedia.org/wiki/Property_list) (OS x plist) | `.plist` |
| [PO 文件](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [低字符串](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [其](http://yaml.org/) | `.yaml` |
| 字幕 | `.srt, .ass, .ssa` |
| HTML | `.html, .htm, .shtml` |
| XML | `.xml` |
| [降价](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| 文本的文件 | `.txt` |
| CSV 文件 | `.csv` |

以下翻译 api 可与 Translatomatic 一起使用:

- [谷歌](https://cloud.google.com/translate/)
- [microsoft](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [yandex](https://tech.yandex.com/translate/)
- [MyMemory](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

翻译字符串都保存在一个数据库和重新使用。

* * *

## 安装

添加这一行为应用程序 `Gemfile`:

`ruby
gem 'translatomatic'
`

然后执行：

    $ bundle

或者安装自己为：

    $ gem install translatomatic

* * *

## 使用

这个宝石提供一个可执行的调用 `translatomatic`中。 的 `translatomatic` 命令有许多功能, 而不是所有这些函数都记录在这里。 有关可用命令和选项的帮助, 请执行以下操作:

    $ translatomatic help

有关命令的帮助, 请执行以下操作:

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

## 安装

检查可用的翻译服务和选项。 `services` 命令:

    $ translatomatic services

可以在命令行、环境变量或 translatomatic 的配置文件中指定选项。 配置文件可以使用 translatomatic 的内部 `config` 命令. 要列出所有可用的配置设置, 请使用:

    $ translatomatic config list
    $ translatomatic config describe

可以在用户级别或项目级别设置选项。 有关详细信息, 请参阅下面的配置部分。

* * *

# # 翻译文件

翻译文件时, `translatomatic` 翻译文本的一句话或短语的时间。 如果文件是流传的, 则只会将自上次翻译以来已更改的句子发送到转换器, 其余的则来自本地数据库。

使用 Google 翻译器将 Java 属性文件转换为德语和法语:

    $ translatomatic translate file --translator Google strings.properties de,fr

这将创建(或复盖) `strings_de.properties` 和 `strings_fr.properties` 具有翻译的属性。

### 显示串从资源束

阅读和显示的 `store.description` 和 `store.name` 性能从当地资源文件中的英文、德文和法文：

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### 提取串自源文件

若要从源文件中提取字符串, 请使用 `strings` 命令, 例如

    $ translatomatic strings file.rb

* * *

## 转换文件

Translatomatic 可用于将文件从一种格式转换为另一种形式。 例如, 要将 Java 属性文件转换为 XCode 字符串文件:

    $ translatomatic convert strings.properties Localization.strings

* * *

## 配置

Translatomatic 的每个用户配置文件位于 `$HOME/.translatomatic/config.yml`, 还可以选择每个项目配置文件 `$PROJECT_DIR/.translatomatic/config.yml`中。 的e `translatomatic config set` 在包含 translatomatic 配置文件的项目中执行时, 命令对项目级别配置进行操作。则, 用户级别配置文件将被更改。 The `--context` 选项可用于指定 `user` 或 `project` 级别配置。 配置选项的有效值是通过从环境中读取、用户级别配置文件、项目级别配置文件 (如果存在) 以及命令行来确定的。 找到的最后一个值优先于先前读取的值。

### Translatomatic 配置示例

要设置 `google_api_key` 在用户配置文件中, 使用:

    $ translatomatic config set google_api_key value --context user

要设置一个或多个要使用的翻译服务:

    $ translatomatic config set translator Microsoft,Yandex

只有当使用第一个选项时发生翻译错误时, 才能使用辅助翻译器。

设置目标语言环境的默认列表:

    $ translatomatic config set target_locales en,de,es,fr,it

与 `target_locales` 设置, 可以在不指定目标区域设置的情况下转换文件。 `translate file` 命令.

    $ translatomatic translate file resources/strings.properties

要显示当前配置, 请执行

    $ translatomatic config list

### 数据库配置

默认情况下， `translatomatic` 使用sqlite3数据库 `$HOME/.translatomatic/translatomatic.sqlite3` 到店已翻译的字符串。 若要将翻译存储在数据库中, 应安装适当的数据库适配器, 如 `sqlite3` 宝石. Translatomatic 不自动安装数据库适配器。 数据库配置可以通过创建 `database.yml` 文件下 `$HOME/.translatomatic/database.yml` 的 `production` 环境中的，例如

    production:
      adapter: mysql2
      host: db.example.com
      database: translatomatic
      pool: 5
      encoding: utf8
      username: username
      password: password

* * *

# # 贡献

错误报告和拉要求，欢迎在审查在https://github.com/smugglys/translatomatic中。 这个项目的目的是成为一个安全、温馨的空间协作和捐助者都应遵守 [《公约》的贡献](http://contributor-covenant.org) 行为守则。

* * *

# # 许可证

宝石可以作为开放源的条款 [麻省理工学院的许可](https://opensource.org/licenses/MIT)中。

* * *

行为准则

每个人都相互作用的Translatomatic项目的代码库中，问题跟踪、聊天室和邮件列表，预计后续的 [行为守则](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md)中。

_由Translatomatic0.1.2Sat, 06 Jan 2018 22:56:28 +1030 创建_
