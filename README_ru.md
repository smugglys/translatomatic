[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Переводит текстовые файлы с одного языка на другой или из одного формата в другой. В настоящее время поддерживаются следующие форматы файлов:

| Формат файла | расширения |
| --- | --- |
| [свойства](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| Файлы ресурсов Windows | `.resw, .resx` |
| [Списки свойств](https://en.wikipedia.org/wiki/Property_list) (OSX plist) | `.plist` |
| [PO-файлов](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [XCode строки](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [YAML](http://yaml.org/) | `.yaml` |
| Субтитры | `.srt, .ass, .ssa` |
| HTML | `.html, .htm, .shtml` |
| XML | `.xml` |
| [Уценок](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| Текстовые файлы | `.txt` |
| CSV файлов | `.csv` |

Могут использоваться следующие поставщики перевод с Translatomatic:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [Яндекс](https://tech.yandex.com/translate/)
- [Мои воспоминания](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

Переведенные строки сохраняются в базе данных и повторно.

* * *

## Установки

Добавьте эту строку в свою заявку. `Gemfile`:

`ruby
gem 'translatomatic'
`

А затем выполнить:

    $ bundle

Или установить его самостоятельно, как:

    $ gem install translatomatic

* * *

## Использование

Этот камень предоставляет исполняемый файл, называемый `translatomatic`, В `translatomatic` команда имеет ряд функций, не все из которых описаны здесь. Для получения справки о доступных командах и параметрах выполните:

    $ translatomatic help

И для справки по команде, выполните:

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

## Установки

Проверьте наличие доступных поставщиков перевода и `providers` команда:

    $ translatomatic providers

Параметры могут быть указаны в командной строке, в переменных среды или в файлах конфигурации translatomatic. Конфигурационные файлы могут быть изменены с помощью встроенного языка translatomatic `config` команда. Чтобы просмотреть все доступные параметры конфигурации, используйте:

    $ translatomatic config list
    $ translatomatic config describe

Параметры могут быть установлены на уровне пользователя или уровне проекта. См. Также раздел «Конфигурация» ниже для получения дополнительной информации.

* * *

## Перевод файлов

При переводе файлов, `translatomatic` переводит текст на одно предложение или фразу за раз. Если файл переводится, только предложения, которые были изменены с момента последнего перевода, отправляются поставщику переводов, а остальные - из локальной базы данных.

Чтобы перевести файл свойств Java на немецком и французском языках, используя Google поставщика:

    $ translatomatic translate file --provider Google strings.properties de,fr

Это создаст (или перезапишет) `strings_de.properties` а также `strings_fr.properties` с переведенными свойствами.

### Отображение строк из набора ресурсов

Чтобы прочитать и отобразить `store.description` а также `store.name` свойства из локальных файлов ресурсов на английском, немецком и французском языках:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### Извлечение строк из исходных файлов

Чтобы извлечь строки из исходных файлов, используйте `strings` команды, например

    $ translatomatic strings file.rb

* * *

## Преобразование файлов

Translatomatic может использоваться для преобразования файлов из одного формата в другой. Например, чтобы преобразовать файл свойств Java в файл строк XCode:

    $ translatomatic convert strings.properties Localization.strings

* * *

## Конфигурация

Настройки конфигурации можно читать и записывать с помощью `config get` а также `config set` команды. Translatomatic использует файл конфигурации пользователя в `$HOME/.translatomatic/config.yml`, и необязательно один файл конфигурации проекта `$PROJECT_DIR/.translatomatic/config.yml`,

В `--user` а также `--project` параметры могут использоваться, чтобы сообщить команде читать или записывать `user` или `project` конфигурации.

Параметры конфигурации считываются из переменных среды, файла конфигурации пользователя, файла конфигурации проекта (если имеется) и из командной строки. Последнее найденное значение имеет приоритет над значениями, прочитанными ранее.

При написании конфигурации с помощью `config set` команда, новое значение записывается в файл конфигурации проекта при выполнении в проекте, содержащем файл трансатомной конфигурации, или файл конфигурации пользователя, если нет файла конфигурации проекта.

### Примеры конфигурации Translatomatic

Устанавливать `google_api_key` в файле конфигурации пользователя используйте:

    $ translatomatic config set google_api_key value --user

Чтобы задать одну или несколько услуг перевода для использования:

    $ translatomatic config set provider Microsoft,Yandex

Чтобы задать список целевой локали по умолчанию:

    $ translatomatic config set target_locales en,de,es,fr,it

С `target_locales` set, файлы могут быть переведены без указания целевых локалей в `translate file` команда.

    $ translatomatic translate file resources/strings.properties

Для отображения текущей конфигурации, выполните:

    $ translatomatic config list

### Конфигурация базы данных

По умолчанию, `translatomatic` использует базу данных sqlite3 в `$HOME/.translatomatic/translatomatic.sqlite3` для хранения переведенных строк. Конфигурация базы данных может быть изменена путем создания `database.yml` файл под `$HOME/.translatomatic/database.yml` для `production` окружающей среды, например

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

## Войска

Сообщения об ошибках и запросы на тягу приветствуются на GitHub по адресу https://github.com/smugglys/translatomatic. Этот проект призван стать безопасным, уютным местом для сотрудничества, и участники, как ожидается, будут придерживаться [Участника Пакта](http://contributor-covenant.org) нормы поведения.

* * *

## Лицензия

Жемчуг доступен как открытый источник в соответствии с условиями [Лицензия MIT](https://opensource.org/licenses/MIT),

* * *

## Кодекса поведения

Ожидается, что все, кто взаимодействует с кодовыми базами проекта Translatomatic, будут выпускать трекеры, чаты и списки рассылки [Кодекс поведения](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md),

_translation missing: ru.translatomatic.file.created\_by_
