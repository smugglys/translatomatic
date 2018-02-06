[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Traduce i file di testo da una lingua all&#39;altra o da un formato all&#39;altro. I seguenti formati di file sono attualmente supportati:

| Formato del file | estensioni |
| --- | --- |
| [Proprietà](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| File di risorse di Windows | `.resw, .resx` |
| [Elenchi di proprietà](https://en.wikipedia.org/wiki/Property_list) (Pliste di OSX) | `.plist` |
| [File PO](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [Stringhe XCode](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [YAML](http://yaml.org/) | `.yaml` |
| Sottotitoli | `.srt, .ass, .ssa` |
| HTML | `.html, .htm, .shtml` |
| XML | `.xml` |
| [riduione di prezzo](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| File di testo | `.txt` |
| File CSV | `.csv` |

I seguenti provider di traduzione possono essere utilizzati con Translatomatic:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [La mia memoria](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

Le stringhe tradotte vengono salvate in un database e riutilizzate.

* * *

## Installazione

Aggiungi questa linea alle tue applicazioni `Gemfile`:

`ruby
gem 'translatomatic'
`

E poi eseguire:

    $ bundle

Oppure installalo tu stesso come:

    $ gem install translatomatic

* * *

## Utilizzo

Questa gemma fornisce un eseguibile chiamato `translatomatic`. Il `translatomatic` il comando ha un numero di funzioni, non tutte documentate qui. Per assistenza su comandi e opzioni disponibili, eseguire:

    $ translatomatic help

E per aiuto su un comando, esegui:

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

## Impostare

Controlla i fornitori di servizi di traduzione disponibili e le opzioni con `providers` comando:

    $ translatomatic providers

Le opzioni possono essere specificate sulla riga di comando, nelle variabili di ambiente o nei file di configurazione di translatomatic. I file di configurazione possono essere modificati usando l&#39;interno di translatomatic `config` comando. Per elencare tutte le impostazioni di configurazione disponibili, utilizzare:

    $ translatomatic config list
    $ translatomatic config describe

Le opzioni possono essere impostate a livello di utente o di progetto. Vedi anche la sezione Configurazione di seguito per maggiori informazioni.

* * *

## Tradurre i file

Quando si traducono i file, `translatomatic` traduce il testo una frase o frase alla volta. Se un file viene tradotto nuovamente, solo le frasi che sono state modificate dall&#39;ultima traduzione vengono inviate al fornitore di traduzioni e il resto viene estratto dal database locale.

Per tradurre un file di proprietà Java in tedesco e francese utilizzando il fornitore di Google:

    $ translatomatic translate file --provider Google strings.properties de,fr

Questo creerebbe (o sovrascriverà) `strings_de.properties` e `strings_fr.properties` con proprietà tradotte.

### Visualizzazione di stringhe da un pacchetto di risorse

Per leggere e visualizzare il `store.description` e `store.name` proprietà da file di risorse locali in inglese, tedesco e francese:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### Estrazione di stringhe dai file di origine

Per estrarre le stringhe dai file di origine, utilizzare il `strings` comando, ad es

    $ translatomatic strings file.rb

* * *

## Conversione di file

Translatomatic può essere utilizzato per convertire file da un formato all&#39;altro. Ad esempio, per convertire un file di proprietà Java in un file di stringhe XCode:

    $ translatomatic convert strings.properties Localization.strings

* * *

## Configurazione

Le impostazioni di configurazione possono essere lette e scritte usando il `config get` e `config set` comandi. Translatomatic utilizza un file di configurazione utente su `$HOME/.translatomatic/config.yml`e facoltativamente un file di configurazione per progetto `$PROJECT_DIR/.translatomatic/config.yml`.

Il `--user` e `--project` le opzioni possono essere utilizzate per dire al comando di leggere o scrivere su `user` o `project` configurazione.

Le impostazioni di configurazione vengono lette dalle variabili di ambiente, dal file di configurazione utente, dal file di configurazione del progetto (se presente) e dalla riga di comando. L&#39;ultimo valore trovato ha la precedenza sui valori letti in precedenza.

Quando si scrive sulla configurazione con `config set` comando, il nuovo valore viene scritto nel file di configurazione del progetto quando viene eseguito all&#39;interno di un progetto contenente un file di configurazione translatomatico o il file di configurazione utente se non esiste un file di configurazione del progetto.

### Esempi di configurazione traslatomica

Impostare `google_api_key` all&#39;interno del file di configurazione utente, utilizzare:

    $ translatomatic config set google_api_key value --user

Per impostare uno o più servizi di traduzione da utilizzare:

    $ translatomatic config set provider Microsoft,Yandex

Per impostare un elenco predefinito di impostazioni locali di destinazione:

    $ translatomatic config set target_locales en,de,es,fr,it

Con `target_locales` set, i file possono essere tradotti senza specificare localizzazioni di destinazione nel file `translate file` comando.

    $ translatomatic translate file resources/strings.properties

Per visualizzare la configurazione corrente, eseguire:

    $ translatomatic config list

### Configurazione del database

Di default, `translatomatic` utilizza un database sqlite3 in `$HOME/.translatomatic/translatomatic.sqlite3` per memorizzare stringhe tradotte. La configurazione del database può essere modificata creando un `database.yml` file sotto `$HOME/.translatomatic/database.yml` per il `production` ambiente, ad es

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

## Contribuire

Segnalazioni di bug e richieste di pull sono benvenute su GitHub all&#39;indirizzo https://github.com/smugglys/translatomatic. Questo progetto vuole essere uno spazio sicuro e accogliente per la collaborazione e ci si aspetta che i contributori aderiscano al [Patto del collaboratore](http://contributor-covenant.org) codice di condotta.

* * *

## Licenza

La gemma è disponibile come open source secondo i termini di [Licenza MIT](https://opensource.org/licenses/MIT).

* * *

## Codice di condotta

Si prevede che tutti coloro che interagiscono con le basi di codice del progetto Translatomatic, gli inseguitori di problemi, le chat room e le mailing list seguano il [codice di condotta](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Creato da Translatomatic 0.1.3 Tue, 06 Feb 2018 22:18:17 +1030 https://github.com/smugglys/translatomatic_
