[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Convertit des fichiers de texte d’une langue à l’autre, ou d’un format à un autre. Les formats de fichier suivants sont actuellement pris en charge&nbsp;:

| Format de fichier | Extensions |
| --- | --- |
| [Propriétés](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| Fichiers de ressources de Windows | `.resw, .resx` |
| [Les listes des propriétés de](https://en.wikipedia.org/wiki/Property_list) (OSX plist) | `.plist` |
| [Fichiers PO](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [XCode chaînes](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [YAML](http://yaml.org/) | `.yaml` |
| Sous-titres | `.srt, .ass, .ssa` |
| HTML | `.html, .htm, .shtml` |
| XML | `.xml` |
| [Markdown](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| Les fichiers texte | `.txt` |
| Fichiers CSV | `.csv` |

La traduction suivante API peut être utilisée avec Translatomatic&nbsp;:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/provider/providerapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [MyMemory](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

Les chaînes traduites sont enregistrés dans une base de données et de les réutiliser.

* * *

## Installation

Ajoutez cette ligne à votre application `Gemfile`:

`ruby
gem 'translatomatic'
`

Et puis de l'exécuter:

    $ bundle

Ou installez-le vous-même:

    $ gem install translatomatic

* * *

## Utilisation

Ce bijou offre un exécutable nommé `translatomatic`. Le `translatomatic` commande a un certain nombre de fonctions, pas tous qui sont documentés ici. De l’aide sur les options et les commandes disponibles, exécutez&nbsp;:

    $ translatomatic help

Et de l’aide sur une commande, exécutez&nbsp;:

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

## Le programme d’installation

Recherchez les services de traduction disponibles et les options avec la `services` commande&nbsp;:

    $ translatomatic services

Options peuvent être spécifiées sur la ligne de commande, variables d’environnement, ou dans les fichiers de configuration de translatomatic. Interne de la configuration des fichiers peuvent être modifiés à l’aide de translatomatic `config` commande. Pour répertorier tous les paramètres de configuration disponibles, utilisez&nbsp;:

    $ translatomatic config list
    $ translatomatic config describe

Options peuvent être définies au niveau de l’utilisateur ou au niveau du projet. Voir aussi la section de Configuration ci-dessous pour plus d’informations.

* * *

## Traduction des fichiers

Lors de la conversion des fichiers, `translatomatic` traduire un texte d'une phrase ou d'une phrase à la fois. Si un fichier est re-traduit, seulement les phrases qui ont changé depuis la dernière traduction sont envoyés au traducteur, et les autres proviennent de la base de données locale.

Pour traduire un fichier de propriétés Java allemand et le Français à utiliser le traducteur de Google&nbsp;:

    $ translatomatic translate file --provider Google strings.properties de,fr

Cela permettrait de créer (ou écraser) `strings_de.properties` et `strings_fr.properties` avec traduit les propriétés.

### L'affichage des chaînes de caractères à partir d'un regroupement de ressources

Pour lire et afficher le `store.description` et `store.name` propriétés à partir des fichiers de ressources locales en anglais, en allemand et en français:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### L'extraction de chaînes à partir de fichiers source

Afin d’extraire les chaînes de fichiers source, les `strings` commande, par exemple

    $ translatomatic strings file.rb

* * *

## La conversion des fichiers

Translatomatic peut être utilisé pour convertir des fichiers d’un format à un autre. Par exemple, pour convertir un Java fichier de propriétés à un XCode cordes fichier&nbsp;:

    $ translatomatic convert strings.properties Localization.strings

* * *

## Configuration

Translatomatic est un fichier de configuration par utilisateur au `$HOME/.translatomatic/config.yml`et éventuellement un par fichier de configuration de projet `$PROJECT_DIR/.translatomatic/config.yml`. Lee `translatomatic config set` commande fonctionne sur la configuration au niveau du projet lorsqu’il est exécuté au sein d’un projet contenant un fichier de configuration translatomatic.Sinon, le fichier de configuration au niveau utilisateur est modifié. The `--context` option peut être utilisée pour spécifier `user` ou `project` configuration du niveau. La valeur effective d’une option de configuration est déterminée par la lecture de l’environnement, le fichier de configuration au niveau utilisateur, le fichier de configuration au niveau du projet (le cas échéant) et de la ligne de commande. La dernière valeur trouvée a priorité sur les valeurs lues auparavant.

### Exemples de configuration Translatomatic

Pour définir `google_api_key` dans le fichier de configuration de l’utilisateur, utilisez&nbsp;:

    $ translatomatic config set google_api_key value --context user

Pour définir un ou plusieurs services de traduction à utiliser&nbsp;:

    $ translatomatic config set provider Microsoft,Yandex

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

* * *

## Contribuant

Les rapports de bogues et de tirer les demandes sont les bienvenus sur GitHub à https://github.com/smugglys/translatomatic. Ce projet est destiné à être un coffre-fort, espace accueillant pour la collaboration, et les contributeurs sont tenus de se conformer à la [Contributeur Pacte](http://contributor-covenant.org) code de conduite.

* * *

## Licence

Le bijou est disponible en open source sous les termes de la [Licence MIT](https://opensource.org/licenses/MIT).

* * *

## Code de conduite

Tout le monde l'interaction avec le Translatomatic projet de code, la question des trackers, des salles de discussion et listes de diffusion, il est prévu de suivre l' [Code de conduite](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Créé par Translatomatic 0.1.2 Sat, 06 Jan 2018 22:56:22 +1030_
