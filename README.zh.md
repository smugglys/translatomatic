[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

翻译文本的文件，从一种语文到另一个。 以下文件的格式 目前支持：

- [性能](https://en.wikipedia.org/wiki/.properties)
- RESW(Windows资源文件)
- [酒店名单](https://en.wikipedia.org/wiki/Property_list) (OS x plist)
- HTML
- XML
- [降价](https://en.wikipedia.org/wiki/Markdown)
- [低字符串](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html)
- [其](http://yaml.org/)
- 文本的文件

翻译字符串都保存在一个数据库和重新使用。

## 安装

添加这一行为应用程序 `Gemfile`:

`ruby
gem 'translatomatic'
`

然后执行：

    $ bundle

或者安装自己为：

    $ gem install translatomatic

## 使用

这个宝石提供一个可执行的调用 `translatomatic`中。的e `translatomatic` 命令有许多功能, 而不是所有这些函数都记录在这里。 有关可用命令和选项的帮助, 请执行以下操作:

    $ translatomatic help

对于子命令的帮助, 请执行以下操作:

    $ translatomatic translate help
    $ translatomatic translate help file

### 翻译的文件

翻译文件时, `translatomatic` 翻译文本的一句话或短语的时间。 If a file is re-translated, only s如果文件是流传的, 则只会将自上次翻译以来已更改的句子发送到转换器, 其余的则来自本地数据库。

为清单提供的翻译服务和选择：

    $ translatomatic list

翻译Java性文件，以德语和法语：

    $ translatomatic translate file resources/strings.properties de,fr

这将创建(或复盖) `strings_de.properties` 和 `strings_fr.properties`中。

### 显示串从资源束

阅读和显示的 `store.description` 和 `store.name` 性能从当地资源文件中的英文、德文和法文：

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### 提取串自源文件

提取串从一些来源文件，使用萃取物的命令，例如

    $ translatomatic strings file.rb

## 配置

### Translatomatic 配置文件

许多命令行选项可以配置使用 Translatomatic 的内部 `config` 命令. 例如, 若要设置目标转换语言环境的默认列表, 请执行以下操作:

    $ translatomatic config set target_locales en,de,es,fr,it

与 `target_locales` 设置, 可以在不指定目标区域设置的情况下转换文件。 `translate file` 命令.

    $ translatomatic translate file resources/strings.properties

要显示当前配置, 请执行

    $ translatomatic config list

### 数据库配置

默认情况下， `translatomatic` 使用sqlite3数据库 `$HOME/.translatomatic/translatomatic.sqlite3` 到店已翻译的字符串。 To store translati若要将翻译存储在数据库中, 应安装适当的数据库适配器, 如`sqlite3` 宝石. Translatomatic 不自动安装数据库适配器。 数据库配置可以通过创建 `database.yml` 文件下 `$HOME/.translatomatic/database.yml` 的 `production` 环境中的，例如

    production:
      adapter: mysql2
      host: db.example.com
      database: translatomatic
      pool: 5
      encoding: utf8
      username: username
      password: password

## 贡献

错误报告和拉要求，欢迎在审查在https://github.com/smugglys/translatomatic中。 这个项目的目的是成为一个安全、温馨的空间协作和捐助者都应遵守 [《公约》的贡献](http://contributor-covenant.org) 行为守则。

## 许可证

宝石可以作为开放源的条款 [麻省理工学院的许可](https://opensource.org/licenses/MIT)中。

## 行为守则

每个人都相互作用的Translatomatic项目的代码库中，问题跟踪、聊天室和邮件列表，预计后续的 [行为守则](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md)中。

_Created by Translatomatic 0.1.1 Sun, 31 Dec 2017 17:27:52 +1030_
