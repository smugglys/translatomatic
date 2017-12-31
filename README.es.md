[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Traduce los archivos de texto de un idioma a otro. Los siguientes formatos de archivo están soportadas actualmente:

- [Propiedades](https://en.wikipedia.org/wiki/.properties)
- RESW (Windows archivo de recursos)
- [Las listas de propiedades](https://en.wikipedia.org/wiki/Property_list) (OSX plist)
- HTML
- XML
- [Descuento](https://en.wikipedia.org/wiki/Markdown)
- [XCode cadenas](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html)
- [YAML](http://yaml.org/)
- Los archivos de texto

Traducido cadenas se guardan en una base de datos y volver a utilizar.

## Instalación

Añadir esta línea a su aplicación `Gemfile`:

`ruby
gem 'translatomatic'
`

Y, a continuación, ejecute:

    $ bundle

O instalar usted mismo como:

    $ gem install translatomatic

## El uso de

Esta gema ofrece un ejecutable llamado `translatomatic`. El `translatomatic` comando tiene un número de funciones, no todos los cuales están documentados aquí. Para obtener ayuda sobre los comandos disponibles y opciones, ejecute:

    $ translatomatic help

Y para obtener ayuda sobre un subcomando, ejecutamos:

    $ translatomatic translate help
    $ translatomatic translate help file

### La traducción de los archivos de

Traducción de archivos, `translatomatic` traduce el texto una oración o una frase en un momeSi un archivo es volver a traducido, sólo las frases que han cambiado desde la última traducción se envían al traductor, y el resto provienen de la base de datos local.abase.

A la lista de servicios de traducción y de opciones:

    $ translatomatic list

Para traducir un archivo de propiedades Java para el alemán y el francés:

    $ translatomatic translate file resources/strings.properties de,fr

Esto podría crear (o sobrescribir) `strings_de.properties` y `strings_fr.properties`.

### La visualización de las cuerdas de un paquete de recursos

Para leer y mostrar el `store.description` y `store.name` propiedades de los archivos de recursos locales en inglés, alemán y francés:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### La extracción de las cadenas de los archivos de origen

Para extraer las cadenas de algunos archivos de origen, utilice el comando extraer, por ejemplo,

    $ translatomatic strings file.rb

## Configuración

### Archivo de configuración Translatomatic

Muchos línea de comando opciones pueden configurarse mediante Translatomatic interna del `config` comando. Por ejemplo, para establecer una lista predeterminada de escenarios de traducción de destino, ejecute:

    $ translatomatic config set target_locales en,de,es,fr,it

Con `target_locales` establece, se pueden traducir archivos sin especificar los lugares de destino en el `translate file` comando.

    $ translatomatic translate file resources/strings.properties

Para mostrar la configuración actual, ejecutar

    $ translatomatic config list

### Configuración de base de datos

Por defecto, `translatomatic` utiliza una base de datos sqlite3 en `$HOME/.translatomatic/translatomatic.sqlite3` para almacenar cadenas traducPara guardar las traducciones en una base de datos, debe tener un adaptador de base de datos adecuados instalado, tales como laas the `sqlite3` Gema. Translatomatic no instalar a adaptadores de base de datos automáticamente. La configuración de la base de datos puede cambiarse mediante la creación de un `database.yml` archivo bajo `$HOME/.translatomatic/database.yml` para el `production` medio ambiente, por ejemplo,

    production:
      adapter: mysql2
      host: db.example.com
      database: translatomatic
      pool: 5
      encoding: utf8
      username: username
      password: password

## Contribuir

Los informes de error y tire de las solicitudes son bienvenidas en GitHub en https://github.com/smugglys/translatomatic. Este proyecto está destinado a ser un lugar seguro, acogedor espacio para la colaboración, y los participantes se adhieran a la [Colaborador Pacto](http://contributor-covenant.org) el código de conducta.

## Licencia

La joya está disponible como código abierto bajo los términos de la [Licencia MIT](https://opensource.org/licenses/MIT).

## Código de Conducta

Todo el mundo que interactúan con el Translatomatic del proyecto códigos base, incidencias, salas de chat y listas de correo, se espera que siga el [código de conducta](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Created by Translatomatic 0.1.1 Sun, 31 Dec 2017 17:27:42 +1030_
