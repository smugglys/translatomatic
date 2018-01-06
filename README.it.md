[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Converte file di testo da una lingua a altra, o da un formato a altro. Attualmente sono supportati i seguenti formati di file:

| Formato di file | Estensioni |
| --- | --- |
| [Proprietà](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| File di risorse di Windows | `.resw, .resx` |
| [Elenchi di proprietà](https://en.wikipedia.org/wiki/Property_list) (OSX plist) | `.plist` |
| [File PO](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [XCode stringhe](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [YAML](http://yaml.org/) | `.yaml` |
| HTML | `.html, .htm, .shtml` |
| XML | `.xml` |
| [Markdown](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| I file di testo | `.txt` |

La seguente traduzione API può essere utilizzata con Translatomatic:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [MyMemory](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

Tradotto le stringhe vengono salvati in un database e riutilizzati.

* * *

# # Installazione

Aggiungere questa riga al file dell'applicazione `Gemfile`:

`ruby
gem 'translatomatic'
`

E poi eseguire:

    $ bundle

O installare da soli come:

    $ gem install translatomatic

* * *

# # L'utilizzo

Questo gioiello fornisce un eseguibile chiamato `translatomatic`. Il `translatomatic` comando ha un numero di funzioni, dei quali non tutti sono documentati qui. Per aiuto sulle opzioni e comandi disponibili, eseguire:

    $ translatomatic help

E per un aiuto su un comando, eseguire:

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

# # Installazione

Controllare i servizi di traduzione disponibili e opzioni con la `services` comando:

    $ translatomatic services

Opzioni possono essere specificate nella riga di comando, nelle variabili di ambiente, o nei file di configurazione di translatomatic. La configurazione del file possono essere modificati utilizzando translatomatic interna del `config` comando. Per elencare tutte le impostazioni di configurazione disponibili, utilizzare:

    $ translatomatic config list
    $ translatomatic config describe

Opzioni possono essere impostate a livello di utente o livello di progetto. Vedi anche la sezione di configurazione sotto per ulteriori informazioni.

* * *

# # Traduzione di file

Quando si converte il file, `translatomatic` traduce il testo una frase o una frase alla volta. Se un file è ri-tradotto, soli frasi che sono stati modificati dopo l'ultima traduzione vengono inviati al traduttore, e il resto sono provenienti dal database locale.

Per tradurre un file di proprietà Java in tedesco e francese utilizzando il traduttore di Google:

    $ translatomatic translate file --translator Google strings.properties de,fr

Questo permetterebbe di creare (o sovrascrivere) `strings_de.properties` e `strings_fr.properties` con proprietà tradotta.

### Visualizzazione di stringhe da un pacchetto di risorse

Per leggere e visualizzare il `store.description` e `store.name` proprietà dal file di risorse locali in inglese, tedesco e francese:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### Estrarre le stringhe dal file di origine

Per estrarre le stringhe dal file di origine, utilizzare il `strings` comando, ad es.

    $ translatomatic strings file.rb

* * *

# # Conversione di file

Translatomatic può essere utilizzato per convertire file da un formato a altro. Ad esempio, per convertire un Java file di proprietà a un XCode stringhe di file:

    $ translatomatic convert strings.properties Localization.strings

* * *

# # Configurazione

Translatomatic è un file di configurazione per utente alle `$HOME/.translatomatic/config.yml`e, facoltativamente, una per ogni file di configurazione di progetto `$PROJECT_DIR/.translatomatic/config.yml`. Ile `translatomatic config set` comando opera sulla configurazione del livello di progetto quando viene eseguito all'interno di un progetto contenente un file di configurazione translatomatic.OIn caso contrario viene modificato il file di configurazione a livello di utente.The `--context` opzione può essere utilizzata per specificare `user` o `project` configurazione del livello. Il valore effettivo di un'opzione di configurazione è determinato dalla lettura dall'ambiente, il file di configurazione a livello di utente, il file di configurazione a livello di progetto (se presente) e dalla riga di comando. L'ultimo valore trovato hanno la precedenza sui valori letti in precedenza.

### Esempi di configurazione di Translatomatic

Per impostare `google_api_key` all'interno del file di configurazione utente, utilizzare:

    $ translatomatic config set google_api_key value --context user

Per impostare uno o più servizi di traduzione da utilizzare:

    $ translatomatic config set translator Microsoft,Yandex

Traduttori secondari solo essere utilizzati se si verifica un errore di traduzione quando si utilizza la prima scelta.

Per impostare un elenco predefinito delle impostazioni locali di destinazione:

    $ translatomatic config set target_locales en,de,es,fr,it

Con `target_locales` impostata, il file possono essere tradotto senza specificare impostazioni locali di destinazione nella `translate file` comando.

    $ translatomatic translate file resources/strings.properties

Per visualizzare la configurazione corrente, eseguire

    $ translatomatic config list

### Configurazione del database

Per impostazione predefinita, `translatomatic` utilizza un database sqlite3 in `$HOME/.translatomatic/translatomatic.sqlite3` per memorizzare stringhe tradotte. Per memorizzare traduzioni in un database, è necessario un adattatore di database appropriato installato, come il `sqlite3` gemma. Translatomatic non installa automaticamente schede di database. La configurazione del database può essere modificata mediante la creazione di un `database.yml` file sotto `$HOME/.translatomatic/database.yml` per il `production` ambiente, ad es.

    production:
      adapter: mysql2
      host: db.example.com
      database: translatomatic
      pool: 5
      encoding: utf8
      username: username
      password: password

* * *

# # Contribuendo

Le segnalazioni di Bug e tirare le richieste sono i benvenuti su GitHub a https://github.com/smugglys/translatomatic. Questo progetto è destinato ad essere un sicuro e accogliente spazio per la collaborazione, e i collaboratori sono tenuti a rispettare i [Collaboratore Alleanza](http://contributor-covenant.org) codice di condotta.

* * *

# # Licenza

Il gioiello è disponibile come open source sotto i termini della [La Licenza MIT](https://opensource.org/licenses/MIT).

* * *

# # Codice di condotta

Tutti interagendo con il Translatomatic progetto di basi di codice, issue tracker, chat e mailing list dovrebbe seguire l' [codice di condotta](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Creato da Translatomatic 0.1.2 Sat, 06 Jan 2018 13:04:30 +1030_
