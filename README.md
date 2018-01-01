[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)
[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)
[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)
[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Translates text files from one language to another.  The following file formats
are currently supported:

* [Properties](https://en.wikipedia.org/wiki/.properties)
* RESW (Windows resources file)
* [Property lists](https://en.wikipedia.org/wiki/Property_list) (OSX plist)
* HTML
* XML
* [Markdown](https://en.wikipedia.org/wiki/Markdown)
* [XCode strings](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html)
* [YAML](http://yaml.org/)
* Text files

The following translation APIs can be used with Translatomatic:

* [Google](https://cloud.google.com/translate/)
* [Microsoft](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
* [Yandex](https://tech.yandex.com/translate/)
* [MyMemory](https://mymemory.translated.net/doc/)
* [Frengly](http://www.frengly.com/api)

Translated strings are saved in a database and reused.

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'translatomatic'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install translatomatic

## Usage

This gem provides an executable called `translatomatic`. The `translatomatic` command has a number of functions, not all of which are documented here. For help on available commands and options, execute:

    $ translatomatic help

And for help on a command, execute:

    $ translatomatic translate help
    $ translatomatic translate help file

## Setup

Check for available translation services and options with the `services` command:

    $ translatomatic services

Options can be specified on the command line, in environment variables, or in translatomatic's configuration file. The configuration file can be modified using translatomatic's internal `config` command. To list all available configuration settings, use:

    $ translatomatic config list
    $ translatomatic config describe

See also the Configuration section below for more information.

## Translating files

When translating files, `translatomatic` translates text one sentence or phrase at a time.  If a file is re-translated, only sentences that have changed since the last translation are sent to the translator, and the rest are sourced from the local database.

To translate a Java properties file to German and French using the Google translator:

    $ translatomatic translate file --translator Google strings.properties de,fr

This would create (or overwrite) `strings_de.properties` and `strings_fr.properties` with translated properties.

### Displaying strings from a resource bundle

To read and display the `store.description` and `store.name` properties from local resource files in English, German, and French:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### Extracting strings from source files

To extract strings from some source files, use the `strings` command, e.g.

    $ translatomatic strings file.rb

## Configuration

### Translatomatic configuration examples

To set one or more translation services to use:

    $ translatomatic config set translator Microsoft,Yandex

Secondary translators will only be used if a translation error occurs when using the first choice.

To set a default list of target locales:

    $ translatomatic config set target_locales en,de,es,fr,it

With `target_locales` set, files can be translated without specifying target locales in the `translate file` command.

    $ translatomatic translate file resources/strings.properties

To display the current configuration, execute

    $ translatomatic config list

### Database configuration

By default, `translatomatic` uses an sqlite3 database in `$HOME/.translatomatic/translatomatic.sqlite3` to store translated strings.
To store translations in a database, you should have an appropriate database adapter installed, such as the `sqlite3` gem. Translatomatic does not install database adapters automatically.
The database configuration can be changed by creating a `database.yml` file under `$HOME/.translatomatic/database.yml` for the `production` environment, e.g.

    production:
      adapter: mysql2
      host: db.example.com
      database: translatomatic
      pool: 5
      encoding: utf8
      username: username
      password: password

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/smugglys/translatomatic. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting with the Translatomatic project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).
