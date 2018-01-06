[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Übersetzt Text-Dateien von einer Sprache zur anderen oder von einem Format in ein anderes. Die folgenden Dateiformate werden derzeit unterstützt:

| Datei-format | Erweiterungen |
| --- | --- |
| [Eigenschaften](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| Windows-Ressource-Dateien | `.resw, .resx` |
| [Property-Listen](https://en.wikipedia.org/wiki/Property_list) (OSX plist) | `.plist` |
| [PO-Dateien](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [XCode strings](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [YAML](http://yaml.org/) | `.yaml` |
| HTML | `.html, .htm, .shtml` |
| XML | `.xml` |
| [Markdown](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| Text-Dateien | `.txt` |

Die folgende Übersetzung APIs kann mit Translatomatic verwendet werden:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [MyMemory](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

Übersetzten Zeichenfolgen werden in einer Datenbank gespeichert und wiederverwendet werden.

* * *

## Installation

Fügen Sie diese Zeile in Ihre Anwendung `Gemfile`:

`ruby
gem 'translatomatic'
`

Und dann ausführen:

    $ bundle

Oder Sie installieren es selbst als:

    $ gem install translatomatic

* * *

## Verwendung

Dieses Juwel bietet eine ausführbare Datei namens `translatomatic`. Die `translatomatic` Befehl hat eine Reihe von Funktionen, von denen nicht, die alle hier dokumentiert sind. Hilfe zu verfügbaren Befehle und Optionen ausführen:

    $ translatomatic help

Und für Hilfe zu einem Befehl ausführen:

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

## Setup

Suchen Sie nach verfügbaren Translation Services und Optionen mit der `services` Befehl:

    $ translatomatic services

Optionen können in der Befehlszeile in Umgebungsvariablen oder in Translatomatic der Konfigurationsdateien angegeben werden. Die Konfiguration, die Dateien mit Translatomatic geändert werden können die interne `config` Befehl. Um alle verfügbaren Konfigurationseinstellungen aufzulisten, verwenden Sie:

    $ translatomatic config list
    $ translatomatic config describe

Optionen können auf der Benutzerebene oder Projektebene festgelegt werden. Siehe auch Abschnitt "Konfiguration" unten für weitere Informationen.

* * *

## Übersetzung von Dateien

Bei der Übersetzung von Dateien `translatomatic` übersetzt den text, ein Satz oder auf Zeit. Wenn eine Datei erneut übersetzt ist, nur Sätze, die seit der letzten Übersetzung geändert haben werden an den Übersetzer geschickt, und der Rest aus der lokalen Datenbank bezogen werden.

Um eine Java-Properties-Datei auf Deutsch und Französisch mit den Google-Übersetzer übersetzen:

    $ translatomatic translate file --translator Google strings.properties de,fr

Dies würde zu erstellen (oder überschreiben) `strings_de.properties` und `strings_fr.properties` mit übersetzten Eigenschaften.

### Die Anzeige von Zeichenfolgen aus einem resource-bundle

Auslesen und anzeigen `store.description` und `store.name` Eigenschaften von der lokalen Ressource-Dateien in Englisch, Deutsch und Französisch:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### Extrahieren von Zeichenfolgen aus den Quelldateien

Verwenden, um Zeichenfolgen von Quellcode-Dateien zu extrahieren, die `strings` Befehl, z.B.

    $ translatomatic strings file.rb

* * *

## Dateien konvertieren

Translatomatic kann verwendet werden, Dateien von einem Format in ein anderes zu konvertieren. Z. B. um eine Java zu konvertieren Streicher "Properties"-Datei für ein XCode Datei:

    $ translatomatic convert strings.properties Localization.strings

* * *

## Konfiguration

Translatomatic hat eine benutzerspezifische Konfigurationsdatei an `$HOME/.translatomatic/config.yml`, und optional eine pro Projekt Konfigurationsdatei `$PROJECT_DIR/.translatomatic/config.yml`. Diee `translatomatic config set` Befehl funktioniert auf die Projektkonfiguration Ebene Ausführung innerhalb eines Projekts mit einer Translatomatic-Konfigurationsdatei. Andernfalls wird die Benutzer-Ebene Konfigurationsdatei geändert. The `--context` Option kann verwendet werden, um anzugeben `user` oder `project` Konfiguration der Ebene. Der effektive Wert einer Konfigurationsoption wird durch das Lesen aus der Umwelt, die User-Konfiguration-Datei, der Projekt-Konfiguration-Datei (falls vorhanden) und von der Kommandozeile aus bestimmt. Der letzte Wert gefunden hat Vorrang vor Werte vorher zu lesen.

### Translatomatic Konfigurationsbeispiele

Festzulegende `google_api_key` innerhalb der Benutzer-Konfiguration-Datei verwenden:

    $ translatomatic config set google_api_key value --context user

Eine oder mehrere Übersetzungen zu verwenden, stellen Sie ein:

    $ translatomatic config set translator Microsoft,Yandex

Sekundäre Übersetzer werden nur verwendet, wenn ein Übersetzungsfehler tritt auf, wenn die erste Wahl zu verwenden.

Eine Standardliste von Ziel Gebietsschemas festgelegt:

    $ translatomatic config set target_locales en,de,es,fr,it

Mit `target_locales` einstellen, Dateien ohne Angabe Ziel Gebietsschemas in übersetzt werden können die `translate file` Befehl.

    $ translatomatic translate file resources/strings.properties

Um die aktuelle Konfiguration anzuzeigen, führen Sie

    $ translatomatic config list

### Datenbank-Konfiguration

Standardmäßig `translatomatic` nutzt eine sqlite3 Datenbank, in `$HOME/.translatomatic/translatomatic.sqlite3` zum speichern der übersetzten strings. Um Übersetzungen in einer Datenbank zu speichern, sollte man einen entsprechenden Datenbank-Adapter installiert, wie z. B. die `sqlite3` Gem. Translatomatic installiert Datenbank-Adapter nicht automatisch. Die Datenbank-Konfiguration kann geändert werden, durch die Schaffung einer `database.yml` Datei unter `$HOME/.translatomatic/database.yml` für die `production` Umwelt, z.B.

    production:
      adapter: mysql2
      host: db.example.com
      database: translatomatic
      pool: 5
      encoding: utf8
      username: username
      password: password

* * *

## Beitragen

Bug-reports und pull-requests sind willkommen auf GitHub an https://github.com/smugglys/translatomatic. Dieses Projekt soll zu einem sicheren, einladenden Raum für die Zusammenarbeit und Mitwirkende werden erwartet, um die Einhaltung der [Beitrag Bund](http://contributor-covenant.org) code of conduct.

* * *

## Lizenz

Der Edelstein ist als open source unter den Bedingungen der [MIT-Lizenz](https://opensource.org/licenses/MIT).

* * *

## Verhaltenskodex

Jeder der Interaktion mit dem Translatomatic Projekt codebase, issue-Tracker, chat-rooms und mailing-Listen sollen Folgen [Verhaltenskodex](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Erstellt von Translatomatic 0.1.2 Sat, 06 Jan 2018 13:04:24 +1030_
