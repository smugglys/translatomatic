[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Переводит текстовые файлы с одного языка на другой. Следующие форматы файлов в настоящее время поддерживаются:

- [Свойства](https://en.wikipedia.org/wiki/.properties)
- Файл resw (файл ресурсов Windows)
- [Списки собственность](https://en.wikipedia.org/wiki/Property_list) (На OSX файл plist)
- HTML-код
- В XML
- [Уценок](https://en.wikipedia.org/wiki/Markdown)
- [Строки в xcode](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html)
- [И yaml](http://yaml.org/)
- Текстовые файлы

Следующее перевод интерфейсы API могут использоваться с Translatomatic:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [Яндекс](https://tech.yandex.com/translate/)
- [MyMemory](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

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

Этот самоцвет содержит исполняемый файл под названием `translatomatic`. В `translatomatic` команда имеет ряд функций, не все из которых описаны здесь. Для получения справки по доступных команд и параметров выполните:

    $ translatomatic help

И для справки на подкоманды, выполните:

    $ translatomatic translate help
    $ translatomatic translate help file

### Перевод файлов

При переводе файлов, `translatomatic` перевод текста одно предложение или фразу одновременно. Если файл переведены заново, отправляются только предложений, которые были изменены с момента последнего перевода переводчик, и остальные поступают из локальной базы данных.

В списке доступных переводов и услуги:

    $ translatomatic list

Чтобы перевести файл свойств java на немецком и французском языках:

    $ translatomatic translate file resources/strings.properties de,fr

Это позволит создать (или заменить) `strings_de.properties` и `strings_fr.properties`.

### Отображение строк из комплекта ресурсов

Для чтения и отображения `store.description` и `store.name` свойства локальные файлы ресурсов на английском, немецком и французском языках:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### Извлечение строк из исходных файлов

Для извлечения строк из некоторых исходных файлов, используйте команду извлечь, например

    $ translatomatic strings file.rb

## Конфигурация

### Файл конфигурации Translatomatic

Многие командной строки параметры могут быть настроены с помощью Translatomatic внутреннего `config` команда. Например чтобы задать список по умолчанию цель перевода языков, выполните:

    $ translatomatic config set target_locales en,de,es,fr,it

С `target_locales` задано, файлы могут быть переведены без указания целевой локали в `translate file` команда.

    $ translatomatic translate file resources/strings.properties

Для отображения текущей конфигурации, выполните

    $ translatomatic config list

### Конфигурация базы данных

По умолчанию `translatomatic` использует базу данных sqlite3 в `$HOME/.translatomatic/translatomatic.sqlite3` хранить переведенные строки. Чтобы хранить переводы в базе данных, вы должны иметь соответствующую базу данных адаптер установлен, такие как `sqlite3` драгоценный камень. Translatomatic не устанавливать Адаптеры базы данных автоматически. Конфигурация базы данных можно изменить, создав `database.yml` файл под `$HOME/.translatomatic/database.yml` для `production` среды, например,

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

Все взаимодействия с исходный код проекта Translatomatic, проблеме трекеры, чаты и списки рассылки, как ожидается, следовать [Кодекс поведения](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Созданная Translatomatic 0.1.1 Mon, 01 Jan 2018 13:33:42 +1030_
