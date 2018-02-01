[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

将文本文件从一种语言翻译成另一种语言，或从一种格式翻译成另一种格式。 目前支持以下文件格式：

| 文件格式 | 扩展 |
| --- | --- |
| [属性](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| Windows 资源文件 | `.resw, .resx` |
| [属性列表](https://en.wikipedia.org/wiki/Property_list) （OSX plist） | `.plist` |
| [PO 文件](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [XCode 字符串](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [YAML](http://yaml.org/) | `.yaml` |
| 字幕 | `.srt, .ass, .ssa` |
| HTML | `.html, .htm, .shtml` |
| XML | `.xml` |
| [降价](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| 文本文件 | `.txt` |
| CSV 文件 | `.csv` |

以下翻译提供程序可与 Translatomatic 一起使用:

- [谷歌](https://cloud.google.com/translate/)
- [微软](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [Yandex的](https://tech.yandex.com/translate/)
- [我的记忆](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

已翻译的字符串保存在数据库中并可重用。

* * *

## 安装

将此行添加到您的应用程序的 `Gemfile`：

`ruby
gem 'translatomatic'
`

然后执行:

    $ bundle

或将其安装为:

    $ gem install translatomatic

* * *

## 使用

这个宝石提供了一个可执行文件 `translatomatic`。 该 `translatomatic` 命令有许多功能，并不是所有这些功能都记录在这里。 有关可用命令和选项的帮助，请执行：

    $ translatomatic help

有关命令的帮助, 请执行以下操作:

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

## 安装

检查可用的翻译供应商和选项 `providers` 命令：

    $ translatomatic providers

可以在命令行，环境变量或translatomatic的配置文件中指定选项。 配置文件可以使用translatomatic的内部进行修改 `config` 命令。 要列出所有可用的配置设置，请使用：

    $ translatomatic config list
    $ translatomatic config describe

可以在用户级别或项目级别设置选项。 有关更多信息，另请参阅下面的配置部分。

* * *

# # 翻译文件

翻译文件时， `translatomatic` 一次翻译文本一个句子或短语。 如果文件被重新翻译，那么只有自上次翻译以来发生了变化的句子才会被发送到翻译提供者，其余的来自本地数据库。

使用 Google 提供程序将 Java 属性文件转换为德语和法语:

    $ translatomatic translate file --provider Google strings.properties de,fr

这将创建（或覆盖） `strings_de.properties` 和 `strings_fr.properties` 与翻译的属性。

### 显示资源包中的字符串

阅读并显示 `store.description` 和 `store.name` 英文，德文和法文本地资源文件的属性：

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### 从源文件中提取字符串

从源文件中提取字符串，使用 `strings` 命令，例如

    $ translatomatic strings file.rb

* * *

## 转换文件

Translatomatic可用于将文件从一种格式转换为另一种格式。 例如，要将Java属性文件转换为XCode字符串文件：

    $ translatomatic convert strings.properties Localization.strings

* * *

## 配置

配置设置可以使用 `config get` 和 `config set` 命令。 Translatomatic使用一个用户配置文件 `$HOME/.translatomatic/config.yml`，以及可选的每个项目配置文件 `$PROJECT_DIR/.translatomatic/config.yml`。

该 `--user` 和 `--project` 选项可以用来告诉命令读取或写入 `user` 要么 `project` 组态。

配置设置是从环境变量，用户配置文件，项目配置文件（如果存在）以及从命令行中读取的。 找到的最后一个值优先于先前读取的值。

在写入配置时使用 `config set` 命令，则在包含translatomatic配置文件的项目中执行时，将新值写入项目配置文件，如果没有项目配置文件，则将新值写入用户配置文件。

### Translatomatic 配置示例

设置 `google_api_key` 在用户配置文件中，使用：

    $ translatomatic config set google_api_key value --user

要设置一个或多个要使用的翻译服务:

    $ translatomatic config set provider Microsoft,Yandex

设置目标语言环境的默认列表:

    $ translatomatic config set target_locales en,de,es,fr,it

同 `target_locales` 设置，可以在不指定目标语言环境的情况下转换文件 `translate file` 命令。

    $ translatomatic translate file resources/strings.properties

要显示当前配置, 请执行以下操作:

    $ translatomatic config list

### 数据库配置

默认， `translatomatic` 在中使用一个sqlite3数据库 `$HOME/.translatomatic/translatomatic.sqlite3` 存储翻译的字符串。 数据库配置可以通过创建一个 `database.yml` 文件下 `$HOME/.translatomatic/database.yml` 为了 `production` 环境，例如

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

# # 贡献

在https://github.com/smugglys/translatomatic的GitHub上欢迎Bug报告和请求。 这个项目的目的是成为一个安全的，欢迎的合作空间，贡献者有望坚持 [贡献者盟约](http://contributor-covenant.org) 行为守则。

* * *

# # 许可证

这个宝石可以按照开源的条款来使用 [麻省理工学院许可证](https://opensource.org/licenses/MIT)。

* * *

行为准则

每个人都与Translatomatic项目的代码库，问题跟踪器，聊天室和邮件列表进行交互，预计将遵循 [行为守则](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md)。

_translation missing: zh.translatomatic.file.created\_by_
