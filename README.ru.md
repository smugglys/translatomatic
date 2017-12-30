[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Переводит текстовые файлы с одного языка на другой. Следующие форматы файлов в настоящее время поддерживаются:

- [Свойства](https://en.wikipedia.org/wiki/.properties)
- Файл resw (файл ресурсов Windows)
- [Списки собственность](https://en.wikipedia.org/wiki/Property_list) (На OSX файл plist)
- HTML-код
- В XML
- [Строки в xcode](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html)
- [И yaml](http://yaml.org/)
- Текстовые файлы

Переведенные строки сохраняются в базе данных и повторно.

## Установка

Добавьте в ваши приложения `Gemfile`:

`ruby
gem 'translatomatic'
`

А затем выполнить:

    $ bundle

Или установить его самостоятельно, так как:

    $ gem install translatomatic

## Использование

Интерфейс командной строки для возможности перевода `translatomatic`. Для получения справки о наличии варианта, выполнить:

    $ translatomatic help

### Перевод файлов

`translatomatic` перевод текста одно предложение или фразу одновременно. Если файл переведено, только предложения, которые были изменены, отправляются переводчику, а остальные берутся из локальной базы данных.

В списке доступных переводов и услуги:

    $ translatomatic translators

Чтобы перевести файл свойств java на немецком и французском языках:

    $ translatomatic translate resources/strings.properties de fr

Это позволит создать (или заменить) `strings_de.properties` и `strings_fr.properties`.

### Извлечение строк из исходных файлов

Для извлечения строк из некоторых исходных файлов, используйте команду извлечь, например

    $ translatomatic strings file.rb

### Отображение строк из комплекта ресурсов

Для чтения и отображения `store.description` и `store.name` свойства локальные файлы ресурсов на английском, немецком и французском языках:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

## Конфигурации

По умолчанию `translatomatic` использует базу данных sqlite3 в `$HOME/.translatomatic/translatomatic.sqlite3` хранить переведенные строки. База данных может быть изменена путем создания `database.yml` файл под `$HOME/.translatomatic/database.yml` для `production` среды, например,

    production:
      adapter: mysql2
      host: db.example.com
      database: translatomatic
      pool: 5
      encoding: utf8
      username: username
      password: password

## Войска

Сообщения об ошибках и запросы приветствуются на github в https://github.com/smugglys/translatomatic. Этот проект предназначен, чтобы быть безопасным, гостеприимное пространство для сотрудничества, и участников, как ожидается, придерживаться [Завет Автор](http://contributor-covenant.org) кодекса поведения.

## Лицензия

Камень доступен как открытый источник в соответствии с условиями [Лицензия mit](https://opensource.org/licenses/MIT).

## Кодекс поведения

Все взаимодействия с исходный код проекта Translatomatic, проблеме трекеры, чаты и списки рассылки, как ожидается, следовать [кодекс поведения](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Created by Translatomatic 0.1.1 Sat, 30 Dec 2017 22:53:50 +1030_
