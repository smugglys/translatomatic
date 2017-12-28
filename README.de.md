[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Übersetzt text-Dateien von einer Sprache zur anderen. Die folgenden Datei-Formatewerden derzeit unterstützt::

- [Eigenschaften](https://en.wikipedia.org/wiki/.properties)
- RESW (Windows-Ressourcen-Datei)
- [Eigenschaftslisten](https://en.wikipedia.org/wiki/Property_list) (OSX plist)
- HTML
- XML
- [XCode strings](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html)
- [YAML](http://yaml.org/)
- Textdateien

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

Die command-line-interface für die übersetzung-Funktionalität `translatomatic`. Für Hilfe zu verfügbaren Optionen ausführen:

    $ translatomatic help

### Übersetzen von Dateien

`translatomatic` übersetzt den text, ein Satz oder auf Zeit. Wenn eine Datei neu übersetzt, nur Sätze, die geändert wurden, werden an den übersetzer gesendet, und der rest stammen aus der lokalen Datenbank.

Um eine Liste der verfügbaren übersetzungs-services und-Optionen:

    $ translatomatic translators

Die übersetzung eines Java-properties-Datei, Deutsch und Französisch:

    $ translatomatic translate resources/strings.properties de fr

Dies würde zu erstellen (oder überschreiben) `strings_de.properties` und `strings_fr.properties`.

### Extrahieren von Zeichenfolgen aus den Quelldateien

Zum extrahieren von Zeichenfolgen aus einige source-Dateien, benutzen Sie den extract-Befehl, z.B.

    $ translatomatic strings file.rb

### Die Anzeige von Zeichenfolgen aus einem resource-bundle

Auslesen und anzeigen `store.description` und `store.name` Eigenschaften von der lokalen Ressource-Dateien in Englisch, Deutsch und Französisch:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

## Konfiguration

Standardmäßig `translatomatic` nutzt eine sqlite3 Datenbank, in `$HOME/.translatomatic/translatomatic.sqlite3` zum speichern der übersetzten strings. Die Datenbank kann geändert werden, durch die Schaffung einer `database.yml` Datei unter `$HOME/.translatomatic/database.yml` für die `production` Umwelt, z.B.

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

_Created by Translatomatic 0.1.0 2017-12-28 22:28_
