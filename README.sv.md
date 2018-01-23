[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Översätter textfiler från ett språk till ett annat eller från ett format till ett annat. Följande filformat stöds för tillfället:

| Filformat | Tillägg |
| --- | --- |
| [Egenskaper](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| Windows resursfiler | `.resw, .resx` |
| [Egendom listor](https://en.wikipedia.org/wiki/Property_list) (OSX plist) | `.plist` |
| [PO-filer](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [XCode strängar](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [YAML](http://yaml.org/) | `.yaml` |
| Undertexter | `.srt, .ass, .ssa` |
| HTML - | `.html, .htm, .shtml` |
| XML | `.xml` |
| [Markdown](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| Text filer | `.txt` |
| CSV-filer | `.csv` |

Följande översättning API: er kan användas med Translatomatic:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/provider/providerapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [MyMemory](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

Översatta strängar sparas i en databas och användas på nytt.

* * *

## Installation

Lägg till den här raden till din ansökan `Gemfile`:

`ruby
gem 'translatomatic'
`

Och sedan köra:

    $ bundle

Eller installera det själv:

    $ gem install translatomatic

* * *

## Användning

Denna pärla ger en körbar som kallas `translatomatic`. Den `translatomatic` kommandot har ett antal funktioner, inte alla som dokumenteras här. För hjälp med tillgängliga kommandon och alternativ, kör:

    $ translatomatic help

Och hjälp om ett kommando, kör:

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

## Setup

Kontrollera tillgängliga översättningstjänster och alternativ med den `services` kommandot:

    $ translatomatic services

Alternativ kan anges på kommandoraden, i miljövariabler eller i translatomatic's konfigurationsfiler. Konfigurationen filer kan ändras med hjälp av translatomatic's interna `config` kommandot. För att lista alla tillgängliga konfigurationsinställningar, Använd:

    $ translatomatic config list
    $ translatomatic config describe

Alternativ kan ställas in på användarnivå eller projektnivå. Se även avsnittet konfiguration nedan för mer information.

* * *

## Översätta filer

När översätta filer, `translatomatic` översätter texten en mening eller en fras på en gång. Om en fil är åter översatta, enda meningar som har ändrats sedan den senaste översättningen skickas till översättaren, och resten kommer från den lokala databasen.

Att översätta en Java properties fil till tyska och franska använder Google provider:

    $ translatomatic translate file --provider Google strings.properties de,fr

Detta skulle skapa (eller skriva) `strings_de.properties` och `strings_fr.properties` med översatta egenskaper.

### Visa strängar från en resurs bunt

För att läsa och visa den `store.description` och `store.name` egenskaper från lokal resurs filer i engelska, tyska och franska:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### Extrahering av strängar från källfilerna

Om du vill extrahera strängar från källfiler, den `strings` kommandot, t.ex.

    $ translatomatic strings file.rb

* * *

## Konvertera filer

Translatomatic kan användas för att konvertera filer från ett format till ett annat. Exempelvis för att konvertera en Java strings properties-fil till en XCode fil:

    $ translatomatic convert strings.properties Localization.strings

* * *

## Konfiguration

Translatomatic har en per-användare-konfigurationsfilen på `$HOME/.translatomatic/config.yml`, och eventuellt en per projekt konfigurationsfil `$PROJECT_DIR/.translatomatic/config.yml`. Dene `translatomatic config set` kommandot fungerar på projekt nivå konfigurationen när de utförs inom ett projekt som innehåller en translatomatic konfigurationsfil. Annars ändras användaren nivå konfigurationsfilen. The `--context` alternativet kan användas för att ange `user` eller `project` nivå konfiguration. Det effektiva värdet av ett konfigurationsalternativ bestäms av läsning från miljön, användaren nivå konfigurationsfilen, projektet nivå konfigurationsfilen (i förekommande fall) och från kommandoraden. Det senaste värdet som hittade har företräde framför värden läste tidigare.

### Translatomatic Konfigurationsexempel

Att ställa in `google_api_key` inom användaren konfigurationsfilen, Använd:

    $ translatomatic config set google_api_key value --context user

Ställa in en eller flera översättningstjänster att använda:

    $ translatomatic config set provider Microsoft,Yandex

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

* * *

## Bidrar

Felrapporter och dra förfrågningar är välkomna på GitHub på https://github.com/smugglys/translatomatic. Projektet är avsett att vara en trygg, välkomnande utrymme för samarbete, och bidragsgivare förväntas hålla sig till [Bidragsgivare Förbund](http://contributor-covenant.org) uppförandekoden.

* * *

## Licens

Pärla är tillgänglig som öppen källkod under villkoren i [MIT License](https://opensource.org/licenses/MIT).

* * *

## Uppförandekod

Alla interagerar med Translatomatic projektets codebases, frågan trackers, chattrum och e-postlistor förväntas följa [uppförandekod](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Skapad av Translatomatic 0.1.2 Sat, 06 Jan 2018 22:56:27 +1030_
