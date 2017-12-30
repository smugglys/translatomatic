[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Converte arquivos de texto de um idioma para outro. Os seguintes formatos de arquivo são atualmente suportados:

- [Propriedades](https://en.wikipedia.org/wiki/.properties)
- RESW (recursos do Windows ficheiro)
- [Listas de propriedades](https://en.wikipedia.org/wiki/Property_list) (OSX plist)
- HTML
- XML
- [XCode cadeias de caracteres](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html)
- [YAML](http://yaml.org/)
- Arquivos de texto

Traduzido seqüências de caracteres são salvos em um banco de dados e reutilizados.

## Instalação

Adicione esta linha ao seu aplicativo `Gemfile`:

`ruby
gem 'translatomatic'
`

E, em seguida, execute:

    $ bundle

Ou instalá-lo a si mesmo como:

    $ gem install translatomatic

## Utilização

A interface de linha de comando para a tradução funcionalidade é `translatomatic`. Para obter ajuda sobre as opções disponíveis, execute:

    $ translatomatic help

### Conversão de arquivos

`translatomatic` traduz texto de uma sentença ou frase de cada vez. Se um arquivo é re-traduzido, apenas frases que foram alterados são enviados para o tradutor, e o resto são provenientes de uma base de dados local.

A lista de serviços de tradução disponíveis e opções:

    $ translatomatic translators

Para traduzir um arquivo de propriedades Java para o alemão e o francês:

    $ translatomatic translate resources/strings.properties de fr

Isso poderia criar (ou substituir) `strings_de.properties` e `strings_fr.properties`.

### A extração de seqüências de caracteres a partir de arquivos de origem

Para extrair cadeias de alguns arquivos de origem, use o comando extract, e.g.

    $ translatomatic strings file.rb

### Exibindo seqüências de caracteres a partir de um pacote de recursos

Para ler e exibir o `store.description` e `store.name` propriedades de arquivos de recursos locais em inglês, alemão e francês:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

## Configuração

Por padrão, `translatomatic` usa um banco de dados sqlite3 no `$HOME/.translatomatic/translatomatic.sqlite3` para armazenar as mensagens traduzidas. O banco de dados pode ser alterado através da criação de um `database.yml` em ficheiro `$HOME/.translatomatic/database.yml` para o `production` ambiente, e.g.

    production:
      adapter: mysql2
      host: db.example.com
      database: translatomatic
      pool: 5
      encoding: utf8
      username: username
      password: password

## Contribuir

Relatórios de bugs e puxe pedidos são bem-vindos no GitHub em https://github.com/smugglys/translatomatic. Este projeto destina-se a ser um seguro, acolhedor espaço para a colaboração e colaboradores devem cumprir o [Contribuinte Convênio](http://contributor-covenant.org) código de conduta.

## Licença

A jóia está disponível como código aberto sob os termos da [Licença MIT](https://opensource.org/licenses/MIT).

## Código de Conduta

Todos interagindo com o Translatomatic projeto antigo, issue trackers, salas de bate-papo e listas de discussão é esperado para seguir o [código de conduta](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Created by Translatomatic 0.1.1 Sat, 30 Dec 2017 22:53:49 +1030_
