[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomático

Traduce archivos de texto de un idioma a otro, o de un formato a otro. Los siguientes formatos de archivo son compatibles actualmente:

| Formato de los archivos | Extensiones |
| --- | --- |
| [Características](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| Archivos de recursos de ventanas | `.resw, .resx` |
| [Propiedad listas](https://en.wikipedia.org/wiki/Property_list) (OSX el plist) | `.plist` |
| [Archivos de los PO](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [Cordones de XCode](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [YAML EN OTROS](http://yaml.org/) | `.yaml` |
| Subtítulos en | `.srt, .ass, .ssa` |
| HTML | `.html, .htm, .shtml` |
| XML | `.xml` |
| [Reducción](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| Ficheros texto | `.txt` |
| Archivos de la CSV | `.csv` |

Los siguientes proveedores de traducción pueden utilizarse con Translatomatic:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [Mi memoria](https://mymemory.translated.net/doc/)
- [Frenéticamente](http://www.frengly.com/api)

Cadenas traducidas se guarda en una base de datos y reutilizados.

* * *

## Instalación de la

Agregue esta línea a su aplicación `Gemfile`:

`ruby
gem 'translatomatic'
`

Y entonces ejecuta:

    $ bundle

O instalarlo a sí mismo como:

    $ gem install translatomatic

* * *

## Uso

Esta gema proporciona un ejecutable llamado `translatomatic`. los `translatomatic` comando tiene una serie de funciones, no todas documentadas aquí. Para obtener ayuda sobre los comandos y opciones disponibles, ejecute:

    $ translatomatic help

Y ayuda sobre un comando, ejecutar:

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

## La instalación

Verifique los proveedores y opciones de traducción disponibles con el `providers` mando:

    $ translatomatic providers

Las opciones se pueden especificar en la línea de comando, en variables de entorno o en los archivos de configuración de translatomatic. Los archivos de configuración se pueden modificar usando el interno de translatomatic `config` mando. Para enumerar todas las configuraciones de configuración disponibles, use:

    $ translatomatic config list
    $ translatomatic config describe

Las opciones se pueden configurar a nivel del usuario o del proyecto. Consulte también la sección Configuración a continuación para obtener más información.

* * *

## Traducción de archivos de

Al traducir archivos, `translatomatic` traduce texto una oración o frase a la vez. Si se vuelve a traducir un archivo, solo las oraciones que han cambiado desde la última traducción se envían al proveedor de la traducción, y el resto se obtienen de la base de datos local.

Traducir un archivo de propiedades de Java para alemán y francés mediante el proveedor de Google:

    $ translatomatic translate file --provider Google strings.properties de,fr

Esto crearía (o sobrescribiría) `strings_de.properties` y `strings_fr.properties` con propiedades traducidas

### Visualización de secuencias desde un paquete de recursos

Para leer y mostrar el `store.description` y `store.name` propiedades de los archivos de recursos locales en inglés, alemán y francés:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### Extracción de secuencias de archivos de origen

Para extraer cadenas de archivos fuente, use el `strings` comando, por ejemplo

    $ translatomatic strings file.rb

* * *

## La conversión de archivos

Translatomatic se puede usar para convertir archivos de un formato a otro. Por ejemplo, para convertir un archivo de propiedades de Java en un archivo de cadenas de XCode:

    $ translatomatic convert strings.properties Localization.strings

* * *

## Las configuración

La configuración de configuración se puede leer y escribir usando `config get` y `config set` de órdenes. Translatomatic utiliza un archivo de configuración de usuario en `$HOME/.translatomatic/config.yml`y, opcionalmente, un archivo de configuración de proyecto `$PROJECT_DIR/.translatomatic/config.yml`.

los `--user` y `--project` Las opciones se pueden usar para indicar al comando que lea o escriba en el `user` o `project` configuración.

Las configuraciones de configuración se leen desde variables de entorno, el archivo de configuración del usuario, el archivo de configuración del proyecto (si está presente) y desde la línea de comando. El último valor encontrado tiene prioridad sobre los valores leídos anteriormente.

Al escribir en la configuración con el `config set` comando, el nuevo valor se escribe en el archivo de configuración del proyecto cuando se ejecuta dentro de un proyecto que contiene un archivo de configuración translatomático, o el archivo de configuración del usuario si no hay un archivo de configuración del proyecto.

### Ejemplos de la configuración Translatomatic

Para establecer `google_api_key` dentro del archivo de configuración del usuario, use:

    $ translatomatic config set google_api_key value --user

Para establecer uno o más servicios de traducción para uso:

    $ translatomatic config set provider Microsoft,Yandex

Para configurar una lista predeterminada de localidades objetivo:

    $ translatomatic config set target_locales en,de,es,fr,it

Con `target_locales` establecer, los archivos se pueden traducir sin especificar las configuraciones regionales de destino en `translate file` mando.

    $ translatomatic translate file resources/strings.properties

Para visualizar la configuración actual, ejecuta:

    $ translatomatic config list

### Configuración la base de datos

Por defecto, `translatomatic` utiliza una base de datos sqlite3 en `$HOME/.translatomatic/translatomatic.sqlite3` para almacenar cadenas traducidas La configuración de la base de datos se puede cambiar creando un `database.yml` archivo debajo `$HOME/.translatomatic/database.yml` Para el `production` medio ambiente, por ejemplo

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

## Contribución

Los informes de errores y las solicitudes de extracción son bienvenidos en GitHub en https://github.com/smugglys/translatomatic. Este proyecto pretende ser un espacio seguro y acogedor para la colaboración, y se espera que los contribuyentes se adhieran a la [Contribuyente de Convenio](http://contributor-covenant.org) código de Conducta.

* * *

## De licencia

La gema está disponible como fuente abierta bajo los términos de la [MIT de licencia](https://opensource.org/licenses/MIT).

* * *

## Código de comportamiento

Se espera que todos los que interactúan con las bases de código del proyecto Translatomatic, los rastreadores de problemas, las salas de chat y las listas de correo sigan el [código conducta](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Creado de Translatomatic 0.1.3 Thu, 01 Feb 2018 21:35:40 +1030 https://github.com/smugglys/translatomatic_
