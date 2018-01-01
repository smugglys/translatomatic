[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Convertit des fichiers à partir d'une langue à l'autre. Les formats de fichier suivants sont actuellement pris en charge:

- [Propriétés](https://en.wikipedia.org/wiki/.properties)
- RESW (ressources Windows fichier)
- [Les listes des propriétés de](https://en.wikipedia.org/wiki/Property_list) (OSX plist)
- HTML
- XML
- [Markdown](https://en.wikipedia.org/wiki/Markdown)
- [XCode chaînes](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html)
- [YAML](http://yaml.org/)
- Les fichiers texte

La traduction suivante API peut être utilisée avec Translatomatic&nbsp;:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [MyMemory](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

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

Ce bijou offre un exécutable nommé `translatomatic`. Le `translatomatic` commande a un certain nombre de fonctions, pas tous qui sont documentés ici. De l’aide sur les options et les commandes disponibles, exécutez&nbsp;:

    $ translatomatic help

Et de l’aide sur une commande, exécutez&nbsp;:

    $ translatomatic translate help
    $ translatomatic translate help file

## Programme d’installation

Recherchez les services de traduction disponibles et les options avec la `services` commande&nbsp;:

    $ translatomatic services

Options peuvent être spécifiées sur la ligne de commande, dans les variables d’environnement, ou dans le fichier de configuration de translatomatic. Le fichier de configuration peut être modifié à l’aide interne du translatomatic `config` commande. Pour répertorier tous les paramètres de configuration disponibles, utilisez&nbsp;:

    $ translatomatic config list
    $ translatomatic config describe

Voir aussi la section de Configuration ci-dessous pour plus d’informations.

## Traduction de fichiers

Lors de la conversion des fichiers, `translatomatic` traduire un texte d'une phrase ou d'une phrase à la fois. Si un fichier est re-traduit, seulement les phrases qui ont changé depuis la dernière traduction sont envoyés au traducteur, et les autres proviennent de la base de données locale.

Pour traduire un fichier de propriétés Java allemand et le Français à utiliser le traducteur de Google&nbsp;:

    $ translatomatic translate file --translator Google strings.properties de,fr

Cela permettrait de créer (ou écraser) `strings_de.properties` et `strings_fr.properties` avec traduit les propriétés.

### L'affichage des chaînes de caractères à partir d'un regroupement de ressources

Pour lire et afficher le `store.description` et `store.name` propriétés à partir des fichiers de ressources locales en anglais, en allemand et en français:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### L'extraction de chaînes à partir de fichiers source

Afin d’extraire les chaînes de certains fichiers source, les `strings` commande, par exemple

    $ translatomatic strings file.rb

## Configuration

### Exemples de configuration Translatomatic

Pour définir un ou plusieurs services de traduction à utiliser&nbsp;:

    $ translatomatic config set translator Microsoft,Yandex

Les traducteurs secondaires serviront uniquement si une erreur de conversion se produit lorsque vous utilisez le premier choix.

Pour définir une liste par défaut des paramètres régionaux cibles&nbsp;:

    $ translatomatic config set target_locales en,de,es,fr,it

Avec `target_locales` définie, les fichiers peuvent être traduits sans spécifier de paramètres régionaux cibles dans le `translate file` commande.

    $ translatomatic translate file resources/strings.properties

Pour afficher la configuration actuelle, exécutez

    $ translatomatic config list

### Configuration de la base de données

Par défaut, `translatomatic` utilise une base de données sqlite3 dans `$HOME/.translatomatic/translatomatic.sqlite3` pour stocker des chaînes traduites. Pour stocker les traductions dans une base de données, vous devez avoir un adaptateur de base de données appropriée installé, tels que la `sqlite3` GEM. Translatomatic n’installe pas automatiquement les cartes de base de données. La configuration de base de données peut être modifiée en créant un `database.yml` fichier sous `$HOME/.translatomatic/database.yml` pour l' `production` l'environnement, par exemple

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

## Code de conduite

Tout le monde l'interaction avec le Translatomatic projet de code, la question des trackers, des salles de discussion et listes de diffusion, il est prévu de suivre l' [Code de conduite](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Créé par Translatomatic 0.1.1 Mon, 01 Jan 2018 21:36:19 +1030_
