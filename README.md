[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)
[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)
[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)

# Translatomatic

Translates text files from one language to another.

Features:
- Translated strings are saved in a database and reused.
- Understands how to translate different types of files, e.g. java properties, xcode strings, YAML, text, markdown.

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

## Example Usage

To list available translation backends and options:

    $ translatomatic translators

To translate a java properties file to German and French:

    $ translatomatic src/main/resources/strings.properties de fr

This would create the following files.

    src/main/resources/strings_de.properties
    src/main/resources/strings_fr.properties

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

Everyone interacting in the Translatomatic project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).
