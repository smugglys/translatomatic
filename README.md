[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)
[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)
[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)

# Translatomatic

Translates text files from one language to another.  The following file formats
are currently supported:

* [Properties](https://en.wikipedia.org/wiki/.properties)
* RESW (Windows resources file)
* [Property lists](https://en.wikipedia.org/wiki/Property_list) (OSX plist)
* HTML
* XML
* [XCode strings](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html)
* [YAML](http://yaml.org/)
* Text files

Translated strings are saved in a database and reused.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'translatomatic'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install translatomatic

## Usage

The command line interface for translation functionality is **translatomatic**. For help on available options, execute:

    $ translatomatic help

### Translating files

To list available translation backends and options:

    $ translatomatic translators

To translate a java properties file to German and French:

    $ translatomatic translate resources/strings.properties de fr

This would create (or overwrite) *strings_de.properties* and *strings_fr.properties*.

### Extracting strings from source files

To extract strings from some source files, use the extract command, e.g.

    $ translatomatic strings file.rb

### Displaying strings from a resource bundle

To read and display the *store.description* and *store.name* properties from local resource files in English, German, and French:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

## Configuration

By default, translatomatic uses an sqlite3 database in *$HOME/.translatomatic/translatomatic.sqlite3* to store translated strings.
The database can be changed by creating a *database.yml* file under *$HOME/.translatomatic/database.yml* for the **production** environment, e.g.

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
