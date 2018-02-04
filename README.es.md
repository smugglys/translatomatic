[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomático

Traduce archivos de texto de un idioma a otro, o de un formato a otro. Los siguientes formatos de archivo son compatibles actualmente:

| Formato de archivo | Extensiones |
| --- | --- |
| [Propiedades](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| Archivos de recursos de Windows | `.resw, .resx` |
| [Listas de propiedades](https://en.wikipedia.org/wiki/Property_list) (OSX plist) | `.plist` |
| [Archivos PO](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [Cadenas de XCode](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [YAML](http://yaml.org/) | `.yaml` |
| Subtítulos | `.srt, .ass, .ssa` |
| HTML | `.html, .htm, .shtml` |
| XML | `.xml` |
| [Reducción](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| Archivos de texto | `.txt` |
| Archivos CSV | `.csv` |

Los siguientes proveedores de traducción se pueden usar con Translatomatic:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [Mi memoria](https://mymemory.translated.net/doc/)
- [Frenéticamente](http://www.frengly.com/api)

Las cadenas traducidas se guardan en una base de datos y se vuelven a usar.

* * *

## Instalación

Agregue esta línea a su aplicación `Gemfile`:

`ruby
gem 'translatomatic'
`

Y luego ejecuta:

    $ bundle

O instálelo usted mismo como:

    $ gem install translatomatic

* * *

## Uso

Esta gema proporciona un ejecutable llamado `translatomatic`. los `translatomatic` comando tiene una serie de funciones, no todas documentadas aquí. Para obtener ayuda sobre los comandos y opciones disponibles, ejecute:

    $ translatomatic help

Y para obtener ayuda con un comando, ejecuta:

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

## Preparar

Verifique los proveedores y opciones de traducción disponibles con el `providers` mando:

    $ translatomatic providers

Las opciones se pueden especificar en la línea de comando, en variables de entorno o en los archivos de configuración de translatomatic. Los archivos de configuración se pueden modificar usando el interno de translatomatic `config` mando. Para enumerar todas las configuraciones de configuración disponibles, use:

    $ translatomatic config list
    $ translatomatic config describe

Las opciones se pueden configurar a nivel del usuario o del proyecto. Consulte también la sección Configuración a continuación para obtener más información.

* * *

## Traducción de archivos

Al traducir archivos, `translatomatic` traduce texto una oración o frase a la vez. Si se vuelve a traducir un archivo, solo las oraciones que han cambiado desde la última traducción se envían al proveedor de la traducción, y el resto se obtienen de la base de datos local.

Para traducir un archivo de propiedades de Java a alemán y francés utilizando el proveedor de Google:

    $ translatomatic translate file --provider Google strings.properties de,fr

Esto crearía (o sobrescribiría) `strings_de.properties` y `strings_fr.properties` con propiedades traducidas

### Mostrar cadenas desde un paquete de recursos

Para leer y mostrar el `store.description` y `store.name` propiedades de los archivos de recursos locales en inglés, alemán y francés:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### Extracción de cadenas de archivos de origen

Para extraer cadenas de archivos fuente, use el `strings` comando, por ejemplo

    $ translatomatic strings file.rb

* * *

## Convertir archivos

Translatomatic se puede usar para convertir archivos de un formato a otro. Por ejemplo, para convertir un archivo de propiedades de Java en un archivo de cadenas de XCode:

    $ translatomatic convert strings.properties Localization.strings

* * *

## Configuración

La configuración de configuración se puede leer y escribir usando `config get` y `config set` comandos. Translatomatic utiliza un archivo de configuración de usuario en `$HOME/.translatomatic/config.yml`y, opcionalmente, un archivo de configuración de proyecto `$PROJECT_DIR/.translatomatic/config.yml`.

los `--user` y `--project` Las opciones se pueden usar para indicar al comando que lea o escriba en el `user` o `project` configuración.

Las configuraciones de configuración se leen desde variables de entorno, el archivo de configuración del usuario, el archivo de configuración del proyecto (si está presente) y desde la línea de comando. El último valor encontrado tiene prioridad sobre los valores leídos anteriormente.

Al escribir en la configuración con el `config set` comando, el nuevo valor se escribe en el archivo de configuración del proyecto cuando se ejecuta dentro de un proyecto que contiene un archivo de configuración translatomático, o el archivo de configuración del usuario si no hay un archivo de configuración del proyecto.

### Ejemplos de configuración translatomática

Para establecer `google_api_key` dentro del archivo de configuración del usuario, use:

    $ translatomatic config set google_api_key value --user

Para configurar uno o más servicios de traducción para usar:

    $ translatomatic config set provider Microsoft,Yandex

Para establecer una lista predeterminada de configuraciones regionales de destino:

    $ translatomatic config set target_locales en,de,es,fr,it

Con `target_locales` establecer, los archivos se pueden traducir sin especificar las configuraciones regionales de destino en `translate file` mando.

    $ translatomatic translate file resources/strings.properties

Para mostrar la configuración actual, ejecute:

    $ translatomatic config list

### Configuración de la base

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

## Contribuyendo

Los informes de errores y las solicitudes de extracción son bienvenidos en GitHub en https://github.com/smugglys/translatomatic. Este proyecto pretende ser un espacio seguro y acogedor para la colaboración, y se espera que los contribuyentes se adhieran a la [Pacto del colaborador](http://contributor-covenant.org) código de Conducta.

* * *

## License

La gema está disponible como fuente abierta bajo los términos de la [Licencia MIT](https://opensource.org/licenses/MIT).

* * *

## Código de Conducta

Se espera que todos los que interactúan con las bases de código del proyecto Translatomatic, los rastreadores de problemas, las salas de chat y las listas de correo sigan el [código de Conducta](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Creado de Translatomatic 0.1.3 Mon, 05 Feb 2018 08:35:41 +1030 https://github.com/smugglys/translatomatic_
