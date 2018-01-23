[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Traduce archivos de texto de un idioma a otro, o de un formato a otro. Se admiten los siguientes formatos:

| Formato de archivo | Extensiones |
| --- | --- |
| [Propiedades](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| Archivos de recursos de Windows | `.resw, .resx` |
| [Las listas de propiedades](https://en.wikipedia.org/wiki/Property_list) (OSX plist) | `.plist` |
| [Archivos PO](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [XCode cadenas](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [YAML](http://yaml.org/) | `.yaml` |
| Subtítulos | `.srt, .ass, .ssa` |
| HTML | `.html, .htm, .shtml` |
| XML | `.xml` |
| [Descuento](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| Los archivos de texto | `.txt` |
| Archivos CSV | `.csv` |

La traducción siguiente API se puede utilizar con Translatomatic:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/provider/providerapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [MyMemory](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

Traducido cadenas se guardan en una base de datos y volver a utilizar.

* * *

## Instalación

Añadir esta línea a su aplicación `Gemfile`:

`ruby
gem 'translatomatic'
`

Y, a continuación, ejecute:

    $ bundle

O instalar usted mismo como:

    $ gem install translatomatic

* * *

## Uso

Esta gema ofrece un ejecutable llamado `translatomatic`. El `translatomatic` comando tiene un número de funciones, no todos los cuales están documentados aquí. Para obtener ayuda sobre los comandos disponibles y opciones, ejecute:

    $ translatomatic help

Y para obtener ayuda sobre un comando, ejecutar:

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

## Setup

Para servicios de traducción disponibles y opciones con el `services` comando:

    $ translatomatic services

Opciones se pueden especificar en la línea de comandos, variables de entorno, o en los archivos de configuración de translatomatic. La configuración pueden modificar archivos con translatomatic interna del `config` comando. Para mostrar todas las configuraciones disponibles, utilice:

    $ translatomatic config list
    $ translatomatic config describe

Opciones se pueden establecer en el nivel de usuario o el nivel de proyecto. Ver también la sección de configuración a continuación para obtener más información.

* * *

## Traducir archivos

Traducción de archivos, `translatomatic` traduce el texto una oración o una frase en un momento. Si un archivo es volver a traducido, sólo las frases que han cambiado desde la última traducción se envían al traductor, y el resto provienen de la base de datos local.

Para traducir un archivo de propiedades de Java al alemán y al francés con el traductor de Google:

    $ translatomatic translate file --provider Google strings.properties de,fr

Esto podría crear (o sobrescribir) `strings_de.properties` y `strings_fr.properties` con propiedades traducidos.

### La visualización de las cuerdas de un paquete de recursos

Para leer y mostrar el `store.description` y `store.name` propiedades de los archivos de recursos locales en inglés, alemán y francés:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### La extracción de las cadenas de los archivos de origen

Para extraer secuencias de archivos de código fuente, utilizar la `strings` comando, por ejemplo

    $ translatomatic strings file.rb

* * *

## Conversión de archivos

Translatomatic se puede utilizar para convertir archivos de un formato a otro. Por ejemplo, para convertir un Java archivo de propiedades a un XCode cadenas archivo:

    $ translatomatic convert strings.properties Localization.strings

* * *

## Configuración

Translatomatic tiene un archivo de configuración de cada usuario en `$HOME/.translatomatic/config.yml`y, opcionalmente, una por el archivo de configuración del proyecto `$PROJECT_DIR/.translatomatic/config.yml`. Ele `translatomatic config set` comando funciona en la configuración de nivel de proyecto cuando se ejecuta dentro de un proyecto que contiene un archivo de configuración translatomatic.De lo contrario se cambia el archivo de configuración de nivel de usuario. The `--context` opción puede utilizarse para especificar `user` o `project` configuración del nivel. El valor eficaz de una opción de configuración se determina mediante la lectura del medio ambiente, el archivo de configuración de nivel de usuario, el archivo de configuración del nivel de proyecto (si existe) y de la línea de comandos. El último valor encontrado tiene prioridad sobre los valores de leer antes.

### Ejemplos de configuración de Translatomatic

Para establecer `google_api_key` dentro del archivo de configuración de usuario, use:

    $ translatomatic config set google_api_key value --context user

Para establecer uno o más servicios de traducción a utilizar:

    $ translatomatic config set provider Microsoft,Yandex

Traductores secundarias se utilizará sólo si se produce un error de traducción cuando se utiliza la primera opción.

Para establecer una lista predeterminada de localidades objetivo:

    $ translatomatic config set target_locales en,de,es,fr,it

Con `target_locales` establece, se pueden traducir archivos sin especificar los lugares de destino en el `translate file` comando.

    $ translatomatic translate file resources/strings.properties

Para mostrar la configuración actual, ejecutar

    $ translatomatic config list

### Configuración de base de datos

Por defecto, `translatomatic` utiliza una base de datos sqlite3 en `$HOME/.translatomatic/translatomatic.sqlite3` para almacenar cadenas traducidas. Para guardar las traducciones en una base de datos, debe tener un adaptador de base de datos adecuados instalado, tales como la `sqlite3` Gema. Translatomatic no instalar a adaptadores de base de datos automáticamente. La configuración de la base de datos puede cambiarse mediante la creación de un `database.yml` archivo bajo `$HOME/.translatomatic/database.yml` para el `production` medio ambiente, por ejemplo,

    production:
      adapter: mysql2
      host: db.example.com
      database: translatomatic
      pool: 5
      encoding: utf8
      username: username
      password: password

* * *

## Contribuyendo

Los informes de error y tire de las solicitudes son bienvenidas en GitHub en https://github.com/smugglys/translatomatic. Este proyecto está destinado a ser un lugar seguro, acogedor espacio para la colaboración, y los participantes se adhieran a la [Colaborador Pacto](http://contributor-covenant.org) el código de conducta.

* * *

## Licencia

La joya está disponible como código abierto bajo los términos de la [Licencia MIT](https://opensource.org/licenses/MIT).

* * *

## Código de conducta

Todo el mundo que interactúan con el Translatomatic del proyecto códigos base, incidencias, salas de chat y listas de correo, se espera que siga el [código de conducta](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Creado por Translatomatic 0.1.2 Sat, 06 Jan 2018 22:56:22 +1030_
