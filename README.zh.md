[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

翻译文本的文件，从一种语文到另一个。 以下文件的格式 目前支持：

- [性能](https://en.wikipedia.org/wiki/.properties)
- RESW(Windows资源文件)
- [酒店名单](https://en.wikipedia.org/wiki/Property_list) (OS x plist)
- HTML
- XML
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

命令行接口进行翻译的功能 `translatomatic`中。 为帮助在可用的选项，执行：

    $ translatomatic help

### 翻译的文件

`translatomatic` 翻译文本的一句话或短语的时间。 如果文件是重新翻译，只有句已经改变被送到翻译，其余的是来自本地数据库。

为清单提供的翻译服务和选择：

    $ translatomatic translators

翻译Java性文件，以德语和法语：

    $ translatomatic translate resources/strings.properties de fr

这将创建(或复盖) `strings_de.properties` 和 `strings_fr.properties`中。

### 提取串自源文件

提取串从一些来源文件，使用萃取物的命令，例如

    $ translatomatic strings file.rb

### 显示串从资源束

阅读和显示的 `store.description` 和 `store.name` 性能从当地资源文件中的英文、德文和法文：

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

## 配置

默认情况下， `translatomatic` 使用sqlite3数据库 `$HOME/.translatomatic/translatomatic.sqlite3` 到店已翻译的字符串。 该数据库可以改变通过创建一个 `database.yml` 文件下 `$HOME/.translatomatic/database.yml` 的 `production` 环境中的，例如

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

_Created by Translatomatic 0.1.1 Sat, 30 Dec 2017 22:53:54 +1030_
