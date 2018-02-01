[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Översätter textfiler från ett språk till ett annat, eller från ett format till ett annat. Följande filformat stöds för närvarande:

| Filformat | Tillägg |
| --- | --- |
| [Boenden](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| Windows resursfiler | `.resw, .resx` |
| [Egenskapslistor](https://en.wikipedia.org/wiki/Property_list) (OSX-plist) | `.plist` |
| [PO-filer](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [XCode strängar](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [YAML](http://yaml.org/) | `.yaml` |
| undertexter | `.srt, .ass, .ssa` |
| html | `.html, .htm, .shtml` |
| XML | `.xml` |
| [Prissänkning](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| Textfiler | `.txt` |
| CSV-filer | `.csv` |

Följande översättning leverantörer kan användas med Translatomatic:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [Mitt minne](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

Översatta strängar sparas i en databas och återanvändas.

* * *

## Installation

Lägg till den här raden i din ansökans `Gemfile`:

`ruby
gem 'translatomatic'
`

Och sedan kör:

    $ bundle

Eller installera det själv som:

    $ gem install translatomatic

* * *

## Användning

Denna pärla ger en körbar kallad `translatomatic`. De `translatomatic` Kommandot har ett antal funktioner, som inte alla är dokumenterade här. För hjälp med tillgängliga kommandon och alternativ, kör:

    $ translatomatic help

Och hjälp om ett kommando, kör:

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

## Inrätta

Kontrollera efter tillgängliga översättningsleverantörer och alternativ med `providers` kommando:

    $ translatomatic providers

Alternativ kan specificeras på kommandoraden, i miljövariabler eller i translatomatiska konfigurationsfiler. Konfigurationsfilerna kan ändras med hjälp av translatomatics interna `config` kommando. För att lista alla tillgängliga konfigurationsinställningar, använd:

    $ translatomatic config list
    $ translatomatic config describe

Alternativ kan ställas in på användarnivå eller projektnivå. Se även avsnittet Konfiguration nedan för mer information.

* * *

## Översätta filer

När man översätter filer, `translatomatic` översätter text en mening eller fras i taget. Om en fil översätts, skickas endast meningar som har ändrats sedan den senaste översättningen till översättningsleverantören, och resten kommer från den lokala databasen.

Att översätta en Java properties fil till tyska och franska med hjälp av Google-providern:

    $ translatomatic translate file --provider Google strings.properties de,fr

Detta skulle skapa (eller skriva över) `strings_de.properties` och `strings_fr.properties` med översatta egenskaper.

### Visar strängar från en resurssamling

Att läsa och visa `store.description` och `store.name` egenskaper från lokala resursfiler på engelska, tyska och franska:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### Utvinna strängar från källfiler

För att extrahera strängar från källfiler, använd `strings` kommando, t.ex.

    $ translatomatic strings file.rb

* * *

## Konvertera filer

Translatomatic kan användas för att konvertera filer från ett format till ett annat. Om du vill konvertera en Java-egenskapsfil till en XCode-strängfil:

    $ translatomatic convert strings.properties Localization.strings

* * *

## Konfiguration

Konfigurationsinställningarna kan läsas och skrivas med hjälp av `config get` och `config set` kommandon. Translatomatic använder en användarkonfigurationsfil på `$HOME/.translatomatic/config.yml`, och valfritt en per projektkonfigurationsfil `$PROJECT_DIR/.translatomatic/config.yml`.

De `--user` och `--project` Alternativ kan användas för att berätta för kommandot att läsa eller skriva till `user` eller `project` konfiguration.

Konfigurationsinställningarna läses från miljövariabler, användarkonfigurationsfilen, projektkonfigurationsfilen (om den finns) och från kommandoraden. Det hittades sista värdet har företräde framför värden som lästs tidigare.

När du skriver till konfigurationen med `config set` kommando, skrivs det nya värdet till projektkonfigurationsfilen när den körs i ett projekt som innehåller en translatomatisk konfigurationsfil eller användarkonfigurationsfilen om det inte finns någon projektkonfigurationsfil.

### Translatomatic Konfigurationsexempel

Att sätta `google_api_key` Använd användarkonfigurationsfilen:

    $ translatomatic config set google_api_key value --user

Ställa in en eller flera översättningstjänster att använda:

    $ translatomatic config set provider Microsoft,Yandex

Ange en standardlista över målet locales:

    $ translatomatic config set target_locales en,de,es,fr,it

Med `target_locales` set kan filer översättas utan att ange mållänkar i `translate file` kommando.

    $ translatomatic translate file resources/strings.properties

Om du vill visa den aktuella konfigurationen, kör:

    $ translatomatic config list

### Konfiguration av databas

Som standard `translatomatic` använder en sqlite3 databas i `$HOME/.translatomatic/translatomatic.sqlite3` att lagra översatta strängar. Databaskonfigurationen kan ändras genom att skapa en `database.yml` fil under `$HOME/.translatomatic/database.yml` för `production` miljö, t.ex.

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

## Bidrar

Felrapporter och dragförfrågningar är välkomna på GitHub på https://github.com/smugglys/translatomatic. Projektet är avsett att vara ett säkert, välkomnande utrymme för samarbete, och bidragsgivare förväntas följa [Bidragsgivaren förbund](http://contributor-covenant.org) uppförandekod.

* * *

## Licens

Pärlan är tillgänglig som öppen källkod enligt villkoren i [MIT-licens](https://opensource.org/licenses/MIT).

* * *

## Uppförandekod

Alla som interagerar med Translatomatic-projektets kodbaser, frågespårare, chattrum och e-postlistor förväntas följa [uppförandekod](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Skapad av Translatomatic 0.1.3 Thu, 01 Feb 2018 21:35:42 +1030 https://github.com/smugglys/translatomatic_
