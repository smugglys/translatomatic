[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Converte arquivos de texto de um idioma para outro. Os seguintes formatos de arquivo são atualmente suportados:

- [Propriedades](https://en.wikipedia.org/wiki/.properties)
- RESW (recursos do Windows ficheiro)
- [Listas de propriedades](https://en.wikipedia.org/wiki/Property_list) (OSX plist)
- HTML
- XML
- [Markdown](https://en.wikipedia.org/wiki/Markdown)
- [XCode cadeias de caracteres](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html)
- [YAML](http://yaml.org/)
- Arquivos de texto

A tradução seguinte APIs pode ser usada com Translatomatic:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [MyMemory](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

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

Esta gema fornece um arquivo executável chamado `translatomatic`. O `translatomatic` comando tem um número de funções, nem todos que estão documentados aqui. Para obter ajuda sobre os comandos disponíveis e opções, execute:

    $ translatomatic help

E para obter ajuda sobre um subcomando, execute:

    $ translatomatic translate help
    $ translatomatic translate help file

### Conversão de arquivos

Quando a tradução de arquivos, `translatomatic` traduz texto de uma sentença ou frase de cada vez. Se um arquivo é re-traduzido, apenas as frases que foram alterados desde a última tradução são enviadas para o tradutor, e o resto são provenientes de banco de dados local.

A lista de serviços de tradução disponíveis e opções:

    $ translatomatic list

Para traduzir um arquivo de propriedades Java para o alemão e o francês:

    $ translatomatic translate file resources/strings.properties de,fr

Isso poderia criar (ou substituir) `strings_de.properties` e `strings_fr.properties`.

### Exibindo seqüências de caracteres a partir de um pacote de recursos

Para ler e exibir o `store.description` e `store.name` propriedades de arquivos de recursos locais em inglês, alemão e francês:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### A extração de seqüências de caracteres a partir de arquivos de origem

Para extrair cadeias de alguns arquivos de origem, use o comando extract, e.g.

    $ translatomatic strings file.rb

## Configuração

### Translatomatic arquivo de configuração

Linha de comando muitas opções podem ser configuradas usando Translatomatic é interno `config` comando. Por exemplo, para definir uma lista padrão de localidades de tradução de destino, execute:

    $ translatomatic config set target_locales en,de,es,fr,it

Com `target_locales` conjunto, os arquivos podem ser traduzidos sem especificar locais de destino na `translate file` comando.

    $ translatomatic translate file resources/strings.properties

Para exibir a configuração atual, execute

    $ translatomatic config list

### Configuração de banco de dados

Por padrão, `translatomatic` usa um banco de dados sqlite3 no `$HOME/.translatomatic/translatomatic.sqlite3` para armazenar as mensagens traduzidas. Para armazenar as traduções em um banco de dados, você deve ter um adaptador de banco de dados apropriado instalado, tais como o `sqlite3` Gem. Translatomatic não instala automaticamente os adaptadores de banco de dados. A configuração de banco de dados pode ser alterada através da criação de um `database.yml` em ficheiro `$HOME/.translatomatic/database.yml` para o `production` ambiente, e.g.

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

## código de conduta

Todos interagindo com o Translatomatic projeto antigo, issue trackers, salas de bate-papo e listas de discussão é esperado para seguir o [código de conduta](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Criado por Translatomatic 0.1.1 Mon, 01 Jan 2018 13:33:41 +1030_
