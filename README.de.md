[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Übersetzt text-Dateien von einer Sprache zur anderen. Die folgenden Datei-Formate werden derzeit unterstützt:

- [Eigenschaften](https://en.wikipedia.org/wiki/.properties)
- RESW (Windows-Ressourcen-Datei)
- [Property-Listen](https://en.wikipedia.org/wiki/Property_list) (OSX plist)
- HTML
- XML
- [Markdown](https://en.wikipedia.org/wiki/Markdown)
- [XCode strings](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html)
- [YAML](http://yaml.org/)
- Text-Dateien

Die folgende Übersetzung APIs kann mit Translatomatic verwendet werden:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [MyMemory](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

Übersetzten Zeichenfolgen werden in einer Datenbank gespeichert und wiederverwendet werden.

## Installation

Fügen Sie diese Zeile in Ihre Anwendung `Gemfile`:

`ruby
gem 'translatomatic'
`

Und dann ausführen:

    $ bundle

Oder Sie installieren es selbst als:

    $ gem install translatomatic

## Nutzung

Dieses Juwel bietet eine ausführbare Datei namens `translatomatic`. Die `translatomatic` Befehl hat eine Reihe von Funktionen, von denen nicht, die alle hier dokumentiert sind. Hilfe zu verfügbaren Befehle und Optionen ausführen:

    $ translatomatic help

Und, um Hilfe zu einem Unterbefehl ausführen:

    $ translatomatic translate help
    $ translatomatic translate help file

### Übersetzen von Dateien

Bei der Übersetzung von Dateien `translatomatic` übersetzt den text, ein Satz oder auf Zeit. Wenn eine Datei erneut übersetzt ist, nur Sätze, die seit der letzten Übersetzung geändert haben werden an den Übersetzer geschickt, und der Rest aus der lokalen Datenbank bezogen werden.

Um eine Liste der verfügbaren übersetzungs-services und-Optionen:

    $ translatomatic list

Die übersetzung eines Java-properties-Datei, Deutsch und Französisch:

    $ translatomatic translate file resources/strings.properties de,fr

Dies würde zu erstellen (oder überschreiben) `strings_de.properties` und `strings_fr.properties`.

### Die Anzeige von Zeichenfolgen aus einem resource-bundle

Auslesen und anzeigen `store.description` und `store.name` Eigenschaften von der lokalen Ressource-Dateien in Englisch, Deutsch und Französisch:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### Extrahieren von Zeichenfolgen aus den Quelldateien

Zum extrahieren von Zeichenfolgen aus einige source-Dateien, benutzen Sie den extract-Befehl, z.B.

    $ translatomatic strings file.rb

## Konfiguration

### Translatomatic-Konfigurationsdatei

Viele Befehlszeile Optionen konfiguriert werden können, mit Translatomatic die interne `config` Befehl. Beispielsweise legen Sie eine Standardliste von Ziel Übersetzung Gebietsschemas ausführen:

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

## Beitrag

Bug-reports und pull-requests sind willkommen auf GitHub an https://github.com/smugglys/translatomatic. Dieses Projekt soll zu einem sicheren, einladenden Raum für die Zusammenarbeit und Mitwirkende werden erwartet, um die Einhaltung der [Beitrag Bund](http://contributor-covenant.org) code of conduct.

## Lizenz

Der Edelstein ist als open source unter den Bedingungen der [MIT-Lizenz](https://opensource.org/licenses/MIT).

## Verhaltenskodex

Jeder der Interaktion mit dem Translatomatic Projekt codebase, issue-Tracker, chat-rooms und mailing-Listen sollen Folgen [Verhaltenskodex](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Erstellt von Translatomatic 0.1.1 Mon, 01 Jan 2018 13:33:36 +1030_
