[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Convertit des fichiers à partir d'une langue à l'autre. Les formats de fichier suivantssont actuellement pris en charge::

- [Propriétés](https://en.wikipedia.org/wiki/.properties)
- RESW (ressources Windows fichier)
- [Les listes des propriétés de](https://en.wikipedia.org/wiki/Property_list) (OSX plist)
- HTML
- XML
- [XCode chaînes](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html)
- [YAML](http://yaml.org/)
- Les fichiers texte

Les chaînes traduites sont enregistrés dans une base de données et de les réutiliser.

## Installation

Ajoutez cette ligne à votre application `Gemfile`:

`ruby
gem 'translatomatic'
`

Et puis de l'exécuter:

    $ bundle

Ou installez-le vous-même:

    $ gem install translatomatic

## L'utilisation de la

L'interface de ligne de commande pour la fonctionnalité de traduction est `translatomatic`. Pour obtenir de l'aide sur les options disponibles, exécutez:

    $ translatomatic help

### Traduction de fichiers

`translatomatic` traduire un texte d'une phrase ou d'une phrase à la fois. Si un fichier est re-traduit, seules les peines qui ont été modifiés sont envoyés pour le traducteur, et le reste sont obtenus à partir de la base de données locale.

Pour une liste des services de traduction et d'options:

    $ translatomatic translators

Pour traduire un fichier de propriétés Java pour l'allemand et le français:

    $ translatomatic translate resources/strings.properties de fr

Cela permettrait de créer (ou écraser) `strings_de.properties` et `strings_fr.properties`.

### L'extraction de chaînes à partir de fichiers source

Pour extraire les chaînes de certains fichiers source, utilisez la commande extraire, par exemple

    $ translatomatic strings file.rb

### L'affichage des chaînes de caractères à partir d'un regroupement de ressources

Pour lire et afficher le `store.description` et `store.name` propriétés à partir des fichiers de ressources locales en anglais, en allemand et en français:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

## Configuration

Par défaut, `translatomatic` utilise une base de données sqlite3 dans `$HOME/.translatomatic/translatomatic.sqlite3` pour stocker des chaînes traduites. La base de données peut être modifié par la création d'un `database.yml` fichier sous `$HOME/.translatomatic/database.yml` pour l' `production` l'environnement, par exemple

    production:
      adapter: mysql2
      host: db.example.com
      database: translatomatic
      pool: 5
      encoding: utf8
      username: username
      password: password

## Contribuer

Les rapports de bogues et de tirer les demandes sont les bienvenus sur GitHub à https://github.com/smugglys/translatomatic. Ce projet est destiné à être un coffre-fort, espace accueillant pour la collaboration, et les contributeurs sont tenus de se conformer à la [Contributeur Pacte](http://contributor-covenant.org) code de conduite.

## Licence

Le bijou est disponible en open source sous les termes de la [Licence MIT](https://opensource.org/licenses/MIT).

## Code de Conduite

Tout le monde l'interaction avec le Translatomatic projet de code, la question des trackers, des salles de discussion et listes de diffusion, il est prévu de suivre l' [code de conduite](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Created by Translatomatic 0.1.0 2017-12-28 22:45_
