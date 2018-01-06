[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Converte arquivos de texto de um idioma para outro, ou de um formato para outro. São suportados os seguintes formatos de arquivo:

| Formato de arquivo | Extensões |
| --- | --- |
| [Propriedades](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| Arquivos de recurso do Windows | `.resw, .resx` |
| [Listas de propriedades](https://en.wikipedia.org/wiki/Property_list) (OSX plist) | `.plist` |
| [Arquivos PO](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [XCode cadeias de caracteres](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [YAML](http://yaml.org/) | `.yaml` |
| Legendas | `.srt, .ass, .ssa` |
| HTML | `.html, .htm, .shtml` |
| XML | `.xml` |
| [Markdown](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| Arquivos de texto | `.txt` |
| Arquivos CSV | `.csv` |

A tradução seguinte APIs pode ser usada com Translatomatic:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [MyMemory](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

Traduzido seqüências de caracteres são salvos em um banco de dados e reutilizados.

* * *

# # Instalação

Adicione esta linha ao seu aplicativo `Gemfile`:

`ruby
gem 'translatomatic'
`

E, em seguida, execute:

    $ bundle

Ou instalá-lo a si mesmo como:

    $ gem install translatomatic

* * *

# # Uso

Esta gema fornece um arquivo executável chamado `translatomatic`. O `translatomatic` comando tem um número de funções, nem todos que estão documentados aqui. Para obter ajuda sobre os comandos disponíveis e opções, execute:

    $ translatomatic help

E para obter ajuda sobre um comando, execute:

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

# # Configuração

Verificar se há serviços de tradução disponíveis e opções com a `services` comando:

    $ translatomatic services

Opções podem ser especificadas na linha de comando, em variáveis de ambiente, ou em arquivos de configuração do translatomatic. A configuração de arquivos podem ser modificados usando translatomatic é interna `config` comando. Para listar todas as configurações disponíveis, use:

    $ translatomatic config list
    $ translatomatic config describe

Opções podem ser definidas no nível do usuário ou o nível de projeto. Veja também a seção de configuração abaixo para obter mais informações.

* * *

# # Tradução de arquivos

Quando a tradução de arquivos, `translatomatic` traduz texto de uma sentença ou frase de cada vez. Se um arquivo é re-traduzido, apenas as frases que foram alterados desde a última tradução são enviadas para o tradutor, e o resto são provenientes de banco de dados local.

Para traduzir um arquivo de propriedades Java para alemão e francês, usando o Google Tradutor:

    $ translatomatic translate file --translator Google strings.properties de,fr

Isso poderia criar (ou substituir) `strings_de.properties` e `strings_fr.properties` com propriedades traduzidas.

### Exibindo seqüências de caracteres a partir de um pacote de recursos

Para ler e exibir o `store.description` e `store.name` propriedades de arquivos de recursos locais em inglês, alemão e francês:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### A extração de seqüências de caracteres a partir de arquivos de origem

Para extrair sequências de caracteres de arquivos de origem, use o `strings` comando, por exemplo

    $ translatomatic strings file.rb

* * *

# # Convertendo arquivos

Translatomatic pode ser usado para converter arquivos de um formato para outro. Por exemplo, para converter um Java arquivo de propriedades para um XCode cadeias de arquivo:

    $ translatomatic convert strings.properties Localization.strings

* * *

# # Configuração

Translatomatic tem um arquivo de configuração por usuário no `$HOME/.translatomatic/config.yml`e, opcionalmente, um por arquivo de configuração do projeto `$PROJECT_DIR/.translatomatic/config.yml`. Oe `translatomatic config set` comando funciona com a configuração de nível de projeto quando executada dentro de um projeto que contém um arquivo de configuração translatomatic.aso contrário, o arquivo de configuração de nível de usuário é alterado. The `--context` opção pode ser usada para especificar `user` ou `project` configuração de nível. O valor efetivo de uma opção de configuração é determinado pela leitura do ambiente, o arquivo de configuração de nível de usuário, o arquivo de configuração de nível de projeto (se houver) e na linha de comando. O último valor encontrado tem precedência sobre valores lidos anteriormente.

### Translatomatic exemplos de configuração

Para definir `google_api_key` dentro do arquivo de configuração de usuário, use:

    $ translatomatic config set google_api_key value --context user

Para definir um ou mais serviços de tradução para usar:

    $ translatomatic config set translator Microsoft,Yandex

Tradutores secundários serão usados apenas se ocorrer um erro de tradução, ao usar a primeira escolha.

Para definir uma lista padrão de localidades de destino:

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

* * *

# # Contribuindo

Relatórios de bugs e puxe pedidos são bem-vindos no GitHub em https://github.com/smugglys/translatomatic. Este projeto destina-se a ser um seguro, acolhedor espaço para a colaboração e colaboradores devem cumprir o [Contribuinte Convênio](http://contributor-covenant.org) código de conduta.

* * *

# # Licença

A jóia está disponível como código aberto sob os termos da [Licença MIT](https://opensource.org/licenses/MIT).

* * *

# # Código de conduta

Todos interagindo com o Translatomatic projeto antigo, issue trackers, salas de bate-papo e listas de discussão é esperado para seguir o [código de conduta](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Criado por Translatomatic 0.1.2 Sat, 06 Jan 2018 22:56:26 +1030_
