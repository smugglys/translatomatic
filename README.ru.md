[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Преобразует текстовые файлы из одного языка в другой или из одного формата в другой. В настоящее время поддерживаются следующие форматы файлов:

| Формат файла | Расширения |
| --- | --- |
| [Свойства](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| Файлы ресурсов Windows | `.resw, .resx` |
| [Списки собственность](https://en.wikipedia.org/wiki/Property_list) (На OSX файл plist) | `.plist` |
| [PO-файлов](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [Строки в xcode](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [И yaml](http://yaml.org/) | `.yaml` |
| HTML-код | `.html, .htm, .shtml` |
| В XML | `.xml` |
| [Уценок](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| Текстовые файлы | `.txt` |

Следующее перевод интерфейсы API могут использоваться с Translatomatic:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [Яндекс](https://tech.yandex.com/translate/)
- [MyMemory](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

Переведенные строки сохраняются в базе данных и повторно.

* * *

## Установки

Добавьте в ваши приложения `Gemfile`:

`ruby
gem 'translatomatic'
`

А затем выполнить:

    $ bundle

Или установить его самостоятельно, так как:

    $ gem install translatomatic

* * *

## Использование

Этот самоцвет содержит исполняемый файл под названием `translatomatic`. В `translatomatic` команда имеет ряд функций, не все из которых описаны здесь. Для получения справки по доступных команд и параметров выполните:

    $ translatomatic help

И для справки по команде, выполните:

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

## Установки

Проверить наличие доступных переводческих услуг и варианты с `services` команда:

    $ translatomatic services

Параметры можно указать в командной строке, в переменных среды, или в translatomatic в файлах конфигурации. Файлы можно изменять с помощью translatomatic конфигурации внутреннего `config` команда. Чтобы получить список всех доступных настроек, используйте:

    $ translatomatic config list
    $ translatomatic config describe

Параметры можно задать на уровне пользователя или на уровне проекта. Смотрите также раздел конфигурации ниже для получения дополнительной информации.

* * *

## Перевод файлов

При переводе файлов, `translatomatic` перевод текста одно предложение или фразу одновременно. Если файл переведены заново, отправляются только предложений, которые были изменены с момента последнего перевода переводчик, и остальные поступают из локальной базы данных.

Чтобы перевести файл свойств Java на немецком и французском языках, используя Google Переводчик:

    $ translatomatic translate file --translator Google strings.properties de,fr

Это позволит создать (или заменить) `strings_de.properties` и `strings_fr.properties` с перевод свойства.

### Отображение строк из комплекта ресурсов

Для чтения и отображения `store.description` и `store.name` свойства локальные файлы ресурсов на английском, немецком и французском языках:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### Извлечение строк из исходных файлов

Для извлечения строк из исходных файлов, используйте `strings` команда, например

    $ translatomatic strings file.rb

* * *

## Преобразование файлов

Translatomatic может использоваться для преобразования файлов из одного формата в другой. Например чтобы преобразовать Java файл свойств XCode строк файла:

    $ translatomatic convert strings.properties Localization.strings

* * *

## Конфигурация

Translatomatic имеет файл конфигурации пользователя в `$HOME/.translatomatic/config.yml`и при необходимости в файл конфигурации проекта `$PROJECT_DIR/.translatomatic/config.yml`. Вe `translatomatic config set` команда работает на уровне конфигурации проекта при выполнении в рамках проекта, содержащий файл конфигурации translatomatic.tВ противном случае файл конфигурации уровня пользователя изменяется.he `--context` параметр может использоваться для указания `user` или `project` уровень конфигурации. Эффективное значение параметра конфигурации определяется чтение из окружающей среды, из файла конфигурации уровня пользователя, файл конфигурации уровня проекта (если есть) и из командной строки. Последнее значение имеет приоритет над читать ранее значения.

### Примеры конфигурации Translatomatic

Чтобы установить `google_api_key` в файле конфигурации пользователя используйте:

    $ translatomatic config set google_api_key value --context user

Чтобы задать одну или несколько услуг перевода для использования:

    $ translatomatic config set translator Microsoft,Yandex

Вторичные переводчиков будет использоваться только если перевод ошибка возникает при использовании первого выбора.

Чтобы задать список целевой локали по умолчанию:

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

* * *

## Войска

Сообщения об ошибках и запросы приветствуются на github в https://github.com/smugglys/translatomatic. Этот проект предназначен, чтобы быть безопасным, гостеприимное пространство для сотрудничества, и участников, как ожидается, придерживаться [Завет Автор](http://contributor-covenant.org) кодекса поведения.

* * *

## Лицензия

Камень доступен как открытый источник в соответствии с условиями [Лицензия mit](https://opensource.org/licenses/MIT).

* * *

## Кодекса поведения

Все взаимодействия с исходный код проекта Translatomatic, проблеме трекеры, чаты и списки рассылки, как ожидается, следовать [Кодекс поведения](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Созданная Translatomatic 0.1.2 Sat, 06 Jan 2018 13:04:38 +1030_
