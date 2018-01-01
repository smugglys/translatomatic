[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Översätter text-filer från ett språk till ett annat. Följande filformat för närvarande stöds:

- [Egenskaper](https://en.wikipedia.org/wiki/.properties)
- RESW (Windows resurser fil)
- [Egendom listor](https://en.wikipedia.org/wiki/Property_list) (OSX plist)
- HTML -
- XML
- [Markdown](https://en.wikipedia.org/wiki/Markdown)
- [XCode strängar](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html)
- [YAML](http://yaml.org/)
- Text filer

Följande översättning API: er kan användas med Translatomatic:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [MyMemory](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

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

Denna pärla ger en körbar som kallas `translatomatic`. Den `translatomatic` kommandot har ett antal funktioner, inte alla som dokumenteras här. För hjälp med tillgängliga kommandon och alternativ, kör:

    $ translatomatic help

Och hjälp om ett kommando, kör:

    $ translatomatic translate help
    $ translatomatic translate help file

## Setup

Kontrollera tillgängliga översättningstjänster och alternativ med den `services` kommandot:

    $ translatomatic services

Alternativ kan anges på kommandoraden, i miljövariabler eller i translatomatic's konfigurationsfil. Konfigurationsfilen kan ändras med hjälp av translatomatic's interna `config` kommandot. För att lista alla tillgängliga konfigurationsinställningar, Använd:

    $ translatomatic config list
    $ translatomatic config describe

Se även avsnittet konfiguration nedan för mer information.

## Översättning av filer

När översätta filer, `translatomatic` översätter texten en mening eller en fras på en gång. Om en fil är åter översatta, enda meningar som har ändrats sedan den senaste översättningen skickas till översättaren, och resten kommer från den lokala databasen.

Att översätta en Java properties fil till tyska och franska använder Google translator:

    $ translatomatic translate file --translator Google strings.properties de,fr

Detta skulle skapa (eller skriva) `strings_de.properties` och `strings_fr.properties` med översatta egenskaper.

### Visa strängar från en resurs bunt

För att läsa och visa den `store.description` och `store.name` egenskaper från lokal resurs filer i engelska, tyska och franska:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### Extrahering av strängar från källfilerna

Om du vill extrahera strängar från vissa källfiler, den `strings` kommandot, t.ex.

    $ translatomatic strings file.rb

## Konfiguration

### Translatomatic Konfigurationsexempel

Ställa in en eller flera översättningstjänster att använda:

    $ translatomatic config set translator Microsoft,Yandex

Sekundära översättare kommer endast användas om ett översättningsfel uppträder när du använder det första valet.

Ange en standardlista över målet locales:

    $ translatomatic config set target_locales en,de,es,fr,it

Med `target_locales` Ange, filer kan översättas utan att ange målet locales i den `translate file` kommandot.

    $ translatomatic translate file resources/strings.properties

Om du vill visa den aktuella konfigurationen, utföra

    $ translatomatic config list

### Konfiguration av databas

Som standard `translatomatic` använder en databas i sqlite3 `$HOME/.translatomatic/translatomatic.sqlite3` till butiken översatta strängar. För att spara översättningar i en databas, bör du ha en lämplig databas adapter installerat, såsom den `sqlite3` pärla. Translatomatic installera inte databasen adaptrar automatiskt. Databaskonfigurationen kan ändras genom att skapa en `database.yml` fil under `$HOME/.translatomatic/database.yml` för `production` miljö, t ex

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

## uppförandekod

Alla interagerar med Translatomatic projektets codebases, frågan trackers, chattrum och e-postlistor förväntas följa [uppförandekod](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Skapad av Translatomatic 0.1.1 Mon, 01 Jan 2018 21:36:24 +1030_
