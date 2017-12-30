[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Översätter text-filer från ett språk till ett annat. Följande filformat för närvarande stöds:

- [Egenskaper](https://en.wikipedia.org/wiki/.properties)
- RESW (Windows resurser fil)
- [Egendom listor](https://en.wikipedia.org/wiki/Property_list) (OSX plist)
- HTML -
- XML
- [XCode strängar](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html)
- [YAML](http://yaml.org/)
- Text filer

Översatta strängar sparas i en databas och användas på nytt.

## Installation

Lägg till den här raden till din ansökan `Gemfile`:

`ruby
gem 'translatomatic'
`

Och sedan köra:

    $ bundle

Eller installera det själv:

    $ gem install translatomatic

## Användning

Command line interface för översättning funktionalitet `translatomatic`. För hjälp om tillgängliga alternativ, utföra:

    $ translatomatic help

### Översättning av filer

`translatomatic` översätter texten en mening eller en fras på en gång. Om en fil är åter översätts, bara meningar som har förändrats skickas till översättare, och resten kommer från den lokala databasen.

För att lista tillgängliga översättning tjänst och alternativ:

    $ translatomatic translators

Att översätta en Java egenskaper för filen till tyska och franska:

    $ translatomatic translate resources/strings.properties de fr

Detta skulle skapa (eller skriva) `strings_de.properties` och `strings_fr.properties`.

### Extrahering av strängar från källfilerna

För att extrahera strängar från en viss källa filer, använd kommandot extract, t ex

    $ translatomatic strings file.rb

### Visa strängar från en resurs bunt

För att läsa och visa den `store.description` och `store.name` egenskaper från lokal resurs filer i engelska, tyska och franska:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

## Konfiguration

Som standard `translatomatic` använder en databas i sqlite3 `$HOME/.translatomatic/translatomatic.sqlite3` till butiken översatta strängar. Databasen kan ändras genom att skapa en `database.yml` fil under `$HOME/.translatomatic/database.yml` för `production` miljö, t ex

    production:
      adapter: mysql2
      host: db.example.com
      database: translatomatic
      pool: 5
      encoding: utf8
      username: username
      password: password

## Bidra

Felrapporter och dra förfrågningar är välkomna på GitHub på https://github.com/smugglys/translatomatic. Projektet är avsett att vara en trygg, välkomnande utrymme för samarbete, och bidragsgivare förväntas hålla sig till [Bidragsgivare Förbund](http://contributor-covenant.org) uppförandekoden.

## Licens

Pärla är tillgänglig som öppen källkod under villkoren i [MIT License](https://opensource.org/licenses/MIT).

## Uppförandekod

Alla interagerar med Translatomatic projektets codebases, frågan trackers, chattrum och e-postlistor förväntas följa [uppförandekod](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Created by Translatomatic 0.1.1 Sat, 30 Dec 2017 22:53:52 +1030_
