[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatique

Traduit des fichiers texte d&#39;une langue à une autre ou d&#39;un format à un autre. Les formats de fichiers suivants sont actuellement supportés:

| Format des fichiers | Extensions de |
| --- | --- |
| [Biens](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| Fichiers ressource Windows | `.resw, .resx` |
| [Propriété listes](https://en.wikipedia.org/wiki/Property_list) (Plist d’OS x) | `.plist` |
| [Dossiers de PO](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [Chaînes XCode](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [YAML](http://yaml.org/) | `.yaml` |
| Titres | `.srt, .ass, .ssa` |
| HTML | `.html, .htm, .shtml` |
| XML | `.xml` |
| [Démarquage](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| Fichiers du texte | `.txt` |
| Fichiers des CSV | `.csv` |

Les fournisseurs de traduction suivants peuvent être utilisés avec Translatomatic&nbsp;:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [Ma mémoire](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

Chaînes traduites sont sauvegardées dans une base de données et réutilisés.

* * *

## Installation $

Ajoutez cette ligne à votre application `Gemfile`:

`ruby
gem 'translatomatic'
`

Et, puis exécuter&nbsp;:

    $ bundle

Ou installer vous-même tant que&nbsp;:

    $ gem install translatomatic

* * *

## L’usage

Cette gemme fournit un exécutable appelé `translatomatic`. le `translatomatic` La commande a un certain nombre de fonctions, qui ne sont pas toutes documentées ici. Pour obtenir de l&#39;aide sur les commandes et les options disponibles, exécutez:

    $ translatomatic help

Et pour une aide sur une commande, exécutez&nbsp;:

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

## Configuration

Vérifiez les fournisseurs de traduction et les options disponibles avec `providers` commander:

    $ translatomatic providers

Les options peuvent être spécifiées sur la ligne de commande, dans les variables d&#39;environnement ou dans les fichiers de configuration de translatomatic. Les fichiers de configuration peuvent être modifiés à l&#39;aide de la commande interne de translatomatic `config` commander. Pour répertorier tous les paramètres de configuration disponibles, utilisez:

    $ translatomatic config list
    $ translatomatic config describe

Les options peuvent être définies au niveau de l&#39;utilisateur ou au niveau du projet. Voir aussi la section Configuration ci-dessous pour plus d&#39;informations.

* * *

## Traduisant des fichiers

Lors de la traduction de fichiers, `translatomatic` traduit le texte d&#39;une phrase ou d&#39;une phrase à la fois. Si un fichier est re-traduit, seules les phrases qui ont été modifiées depuis la dernière traduction sont envoyées au fournisseur de traduction, et les autres proviennent de la base de données locale.

Pour traduire un fichier de propriétés de Java à l’allemand et le Français à l’aide du fournisseur de Google&nbsp;:

    $ translatomatic translate file --provider Google strings.properties de,fr

Cela créerait (ou écraserait) `strings_de.properties` et `strings_fr.properties` avec des propriétés traduites.

### Afficher les chaînes dans un groupe de ressources

Pour lire et afficher le `store.description` et `store.name` propriétés à partir de fichiers de ressources locaux en anglais, allemand et français:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### Extraction des chaînes des fichiers source

Pour extraire des chaînes de fichiers source, utilisez le `strings` commande, par exemple

    $ translatomatic strings file.rb

* * *

## Convertir les fichiers

Translatomatic peut être utilisé pour convertir des fichiers d&#39;un format à un autre. Par exemple, pour convertir un fichier de propriétés Java en un fichier de chaînes XCode:

    $ translatomatic convert strings.properties Localization.strings

* * *

## Des configuration

Les paramètres de configuration peuvent être lus et écrits en utilisant `config get` et `config set` commandes. Translatomatic utilise un fichier de configuration utilisateur à `$HOME/.translatomatic/config.yml`, et éventuellement un fichier de configuration par projet `$PROJECT_DIR/.translatomatic/config.yml`.

le `--user` et `--project` les options peuvent être utilisées pour dire à la commande de lire ou d&#39;écrire à la `user` ou de `project` Configuration..

Les paramètres de configuration sont lus à partir des variables d&#39;environnement, du fichier de configuration de l&#39;utilisateur, du fichier de configuration du projet (le cas échéant) et de la ligne de commande. La dernière valeur trouvée a priorité sur les valeurs lues plus tôt.

En écrivant à la configuration avec le `config set` commande, la nouvelle valeur est écrite dans le fichier de configuration du projet lorsqu&#39;elle est exécutée dans un projet contenant un fichier de configuration translatomatique ou dans le fichier de configuration utilisateur s&#39;il n&#39;y a pas de fichier de configuration de projet.

### Exemples de configuration des Translatomatic

Mettre en place `google_api_key` dans le fichier de configuration de l&#39;utilisateur, utilisez:

    $ translatomatic config set google_api_key value --user

Pour définir un ou plusieurs des services de traduction d’utiliser&nbsp;:

    $ translatomatic config set provider Microsoft,Yandex

Pour activer une liste par défaut des paramètres régionaux cibles&nbsp;:

    $ translatomatic config set target_locales en,de,es,fr,it

Avec `target_locales` ensemble, les fichiers peuvent être traduits sans spécifier de paramètres régionaux cibles dans le `translate file` commander.

    $ translatomatic translate file resources/strings.properties

Pour afficher la configuration courante, exécuter&nbsp;:

    $ translatomatic config list

### Configuration Database

Par défaut, `translatomatic` utilise une base de données sqlite3 dans `$HOME/.translatomatic/translatomatic.sqlite3` pour stocker les chaînes traduites. La configuration de la base de données peut être modifiée en créant un `database.yml` fichier sous `$HOME/.translatomatic/database.yml` pour le `production` environnement, par exemple

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

## Contribution

Les rapports de bogues et les demandes d&#39;extraction sont les bienvenus sur GitHub à l&#39;adresse https://github.com/smugglys/translatomatic. Ce projet se veut un espace de collaboration sûr et accueillant, et les contributeurs sont tenus de respecter les [Pacte du collaborateur](http://contributor-covenant.org) code de conduite.

* * *

## De licence

La gemme est disponible en open source selon les termes de la [Licences MIT](https://opensource.org/licenses/MIT).

* * *

## Les code de déontologie

Tout le monde qui interagit avec les bases de code du projet Translatomatic, les traqueurs de problèmes, les forums de discussion et les listes de diffusion devrait suivre [Code de déroulement](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Création par Translatomatic 0.1.3 Thu, 01 Feb 2018 21:35:40 +1030 https://github.com/smugglys/translatomatic_
