[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatisch

Übersetzt Textdateien von einer Sprache in eine andere oder von einem Format in ein anderes. Die folgenden Dateiformate werden derzeit unterstützt:

| Datei Format | Erweiterungen |
| --- | --- |
| [Eigenschaften](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| Windows-Ressourcendateien | `.resw, .resx` |
| [Eigenschaftslisten](https://en.wikipedia.org/wiki/Property_list) (OSX plist) | `.plist` |
| [PO-Dateien](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [XCode-Zeichenfolgen](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [YAML](http://yaml.org/) | `.yaml` |
| Untertitel | `.srt, .ass, .ssa` |
| HTML | `.html, .htm, .shtml` |
| XML | `.xml` |
| [Abschlag](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| Textdateien | `.txt` |
| CSV-Dateien | `.csv` |

Folgende Übersetzungsanbieter können mit Translatomatic verwendet werden:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [Meine Erinnerung](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

Übersetzte Zeichenfolgen werden in einer Datenbank gespeichert und wiederverwendet.

* * *

## Installation

Fügen Sie diese Zeile zu Ihrer Anwendung hinzu `Gemfile`:

`ruby
gem 'translatomatic'
`

Und dann ausführen:

    $ bundle

Oder installiere es selbst als:

    $ gem install translatomatic

* * *

## Verwendung

Dieses Juwel bietet eine ausführbare Datei namens `translatomatic`. Das `translatomatic` Befehl hat eine Reihe von Funktionen, von denen hier nicht alle dokumentiert sind. Um Hilfe zu verfügbaren Befehlen und Optionen zu erhalten, führen Sie Folgendes aus:

    $ translatomatic help

Und um Hilfe zu einem Befehl zu erhalten, führen Sie Folgendes aus:

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

## Konfiguration

Suchen Sie nach verfügbaren Übersetzungsanbietern und Optionen mit dem `providers` Befehl:

    $ translatomatic providers

Optionen können in der Befehlszeile, in Umgebungsvariablen oder in den Konfigurationsdateien von translatomatic angegeben werden. Die Konfigurationsdateien können mit den internen translatomatic geändert werden `config` Befehl. Verwenden Sie Folgendes, um alle verfügbaren Konfigurationseinstellungen aufzulisten:

    $ translatomatic config list
    $ translatomatic config describe

Optionen können auf Benutzerebene oder Projektebene festgelegt werden. Weitere Informationen finden Sie im folgenden Abschnitt Konfiguration.

* * *

## Dateien übersetzen

Beim Übersetzen von Dateien `translatomatic` übersetzt Text einen Satz oder Satz auf einmal. Wenn eine Datei erneut übersetzt wird, werden nur Sätze, die seit der letzten Übersetzung geändert wurden, an den Übersetzungsanbieter gesendet, und der Rest stammt aus der lokalen Datenbank.

So übersetzen Sie eine Java-Eigenschaftendatei mithilfe des Google-Anbieters in Deutsch und Französisch:

    $ translatomatic translate file --provider Google strings.properties de,fr

Dies würde erstellen (oder überschreiben) `strings_de.properties` und `strings_fr.properties` mit übersetzten Eigenschaften.

### Anzeigen von Zeichenfolgen aus einem Ressourcenpaket

Zum Lesen und Anzeigen der `store.description` und `store.name` Eigenschaften aus lokalen Ressourcendateien in Englisch, Deutsch und Französisch:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### Extrahieren von Zeichenfolgen aus Quelldateien

Verwenden Sie den Befehl zum Extrahieren von Zeichenfolgen aus Quelldateien `strings` Befehl, z

    $ translatomatic strings file.rb

* * *

## Konvertieren von Dateien

Translatomatic kann verwendet werden, um Dateien von einem Format in ein anderes zu konvertieren. Um beispielsweise eine Java-Eigenschaftendatei in eine XCode-Zeichenfolgendatei zu konvertieren:

    $ translatomatic convert strings.properties Localization.strings

* * *

## Aufbau

Konfigurationseinstellungen können mit Hilfe des. Gelesen und geschrieben werden `config get` und `config set` Befehle. Translatomatic verwendet eine Benutzerkonfigurationsdatei unter `$HOME/.translatomatic/config.yml`und optional eine pro Projekt Konfigurationsdatei `$PROJECT_DIR/.translatomatic/config.yml`.

Das `--user` und `--project` Optionen können verwendet werden, um den Befehl zum Lesen oder Schreiben an den Befehl anzuweisen `user` oder `project` Aufbau.

Konfigurationseinstellungen werden aus Umgebungsvariablen, der Benutzerkonfigurationsdatei, der Projektkonfigurationsdatei (falls vorhanden) und von der Befehlszeile gelesen. Der letzte gefundene Wert hat Vorrang vor den früher gelesenen Werten.

Beim Schreiben in die Konfiguration mit dem `config set` Befehl wird der neue Wert in die Projektkonfigurationsdatei geschrieben, wenn er in einem Projekt ausgeführt wird, das eine translatomatische Konfigurationsdatei enthält, oder in der Benutzerkonfigurationsdatei, wenn keine Projektkonfigurationsdatei vorhanden ist.

### Translatomatische Konfigurationsbeispiele

Einstellen `google_api_key` Verwenden Sie in der Benutzerkonfigurationsdatei Folgendes:

    $ translatomatic config set google_api_key value --user

So legen Sie einen oder mehrere zu verwendende Übersetzungsdienste fest:

    $ translatomatic config set provider Microsoft,Yandex

So legen Sie eine Standardliste von Zielgebietsschemas fest:

    $ translatomatic config set target_locales en,de,es,fr,it

Mit `target_locales` set können Dateien ohne Angabe von Zielgebietsschemas übersetzt werden `translate file` Befehl.

    $ translatomatic translate file resources/strings.properties

Um die aktuelle Konfiguration anzuzeigen, führen Sie Folgendes aus:

    $ translatomatic config list

### Datenbankkonfiguration

Standardmäßig, `translatomatic` benutzt eine sqlite3 Datenbank in `$HOME/.translatomatic/translatomatic.sqlite3` um übersetzte Strings zu speichern. Die Datenbankkonfiguration kann durch Erstellen einer geändert werden `database.yml` Datei unter `$HOME/.translatomatic/database.yml` für die `production` Umgebung, z

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

## Beitragend

Fehlerberichte und Pull-Anfragen sind auf GitHub unter https://github.com/smugglys/translatomatic willkommen. Dieses Projekt soll ein sicherer und einladender Raum für die Zusammenarbeit sein und es wird erwartet, dass sich die Mitwirkenden an die [Contributor Covenant](http://contributor-covenant.org) Verhaltensregeln.

* * *

## Lizenz

Der Edelstein ist als Open Source unter den Bedingungen der [MIT-Lizenz](https://opensource.org/licenses/MIT).

* * *

## Verhaltensregeln

Jeder, der mit den Codebasen des Translatomatic-Projekts, Issue-Trackern, Chat-Rooms und Mailinglisten interagiert, wird voraussichtlich den [Verhaltensregeln](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Angelegt von Translatomatic 0.1.3 Mon, 05 Feb 2018 08:35:41 +1030 https://github.com/smugglys/translatomatic_
