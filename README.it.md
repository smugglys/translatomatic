[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Converte file di testo da una lingua all'altra. I seguenti formati di filesono attualmente supportati::

- [Proprietà](https://en.wikipedia.org/wiki/.properties)
- RESW (risorse di Windows, file)
- [Elenchi di proprietà](https://en.wikipedia.org/wiki/Property_list) (OSX plist)
- HTML
- XML
- [XCode stringhe](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html)
- [YAML](http://yaml.org/)
- I file di testo

Tradotto le stringhe vengono salvati in un database e riutilizzati.

## Installazione

Aggiungere questa riga al file dell'applicazione `Gemfile`:

`ruby
gem 'translatomatic'
`

E poi eseguire:

    $ bundle

O installare da soli come:

    $ gem install translatomatic

## Utilizzo

L'interfaccia a riga di comando per la traduzione funzionalità `translatomatic`. Per la guida sulle opzioni disponibili, eseguire:

    $ translatomatic help

### La traduzione di file

`translatomatic` traduce il testo una frase o una frase alla volta. Se un file è ri-tradotto, solo frasi che hanno cambiato inviati al traduttore, e il resto provengono dalla banca dati locale.

Elenco di servizi di traduzione ed opzioni:

    $ translatomatic translators

Per tradurre un file delle proprietà Java per il tedesco e il francese:

    $ translatomatic translate resources/strings.properties de fr

Questo permetterebbe di creare (o sovrascrivere) `strings_de.properties` e `strings_fr.properties`.

### Estrarre le stringhe dal file di origine

Per estrarre le stringhe da alcuni file di origine, utilizzare il comando di estrazione, ad es.

    $ translatomatic strings file.rb

### Visualizzazione di stringhe da un pacchetto di risorse

Per leggere e visualizzare il `store.description` e `store.name` proprietà dal file di risorse locali in inglese, tedesco e francese:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

## Configurazione

Per impostazione predefinita, `translatomatic` utilizza un database sqlite3 in `$HOME/.translatomatic/translatomatic.sqlite3` per memorizzare stringhe tradotte. Il database può essere modificato con la creazione di un `database.yml` file sotto `$HOME/.translatomatic/database.yml` per il `production` ambiente, ad es.

    production:
      adapter: mysql2
      host: db.example.com
      database: translatomatic
      pool: 5
      encoding: utf8
      username: username
      password: password

## Contribuire

Le segnalazioni di Bug e tirare le richieste sono i benvenuti su GitHub a https://github.com/smugglys/translatomatic. Questo progetto è destinato ad essere un sicuro e accogliente spazio per la collaborazione, e i collaboratori sono tenuti a rispettare i [Collaboratore Alleanza](http://contributor-covenant.org) codice di condotta.

## Licenza

Il gioiello è disponibile come open source sotto i termini della [La Licenza MIT](https://opensource.org/licenses/MIT).

## Codice di Condotta

Tutti interagendo con il Translatomatic progetto di basi di codice, issue tracker, chat e mailing list dovrebbe seguire l' [codice di condotta](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Created by Translatomatic 0.1.0 2017-12-29 00:07_
