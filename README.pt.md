[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

Traduz arquivos de texto de um idioma para outro, ou de um formato para outro. Atualmente, os seguintes formatos de arquivo são suportados:

| Formato de arquivo | Extensões |
| --- | --- |
| [Propriedades](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| Arquivos de recurso do Windows | `.resw, .resx` |
| [Listas de propriedade.](https://en.wikipedia.org/wiki/Property_list) (OSX plist) | `.plist` |
| [Arquivos PO](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [Cordas de XCode](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [YAML](http://yaml.org/) | `.yaml` |
| Legendas | `.srt, .ass, .ssa` |
| HTML | `.html, .htm, .shtml` |
| XML | `.xml` |
| [Markdown](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| Arquivos de texto | `.txt` |
| Arquivos CSV | `.csv` |

Os seguintes provedores de tradução podem ser usados com Translatomatic:

- [Google](https://cloud.google.com/translate/)
- [Microsoft](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [Minha memória](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

Traduzido de sequências de caracteres são salvos em um banco de dados e reutilizadas.

* * *

# # Instalação

Adicione esta linha à sua aplicação `Gemfile`:

`ruby
gem 'translatomatic'
`

E, em seguida, execute:

    $ bundle

Ou instalá-lo sozinho como:

    $ gem install translatomatic

* * *

## Uso

Esta jóia fornece um executável chamado `translatomatic`. o `translatomatic` O comando possui várias funções, não todas documentadas aqui. Para obter ajuda sobre comandos e opções disponíveis, execute:

    $ translatomatic help

E para obter ajuda sobre um comando, execute:

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

# # Configuração

Verifique os provedores de tradução disponíveis e as opções com o `providers` comando:

    $ translatomatic providers

As opções podem ser especificadas na linha de comando, nas variáveis ​​de ambiente ou nos arquivos de configuração do tradatomatic. Os arquivos de configuração podem ser modificados usando o interno interno do translatomatic. `config` comando. Para listar todas as configurações disponíveis, use:

    $ translatomatic config list
    $ translatomatic config describe

As opções podem ser definidas no nível do usuário ou no nível do projeto. Consulte também a seção Configuração abaixo para obter mais informações.

* * *

# # Tradução de arquivos

Ao traduzir arquivos, `translatomatic` traduz texto uma frase ou frase por vez. Se um arquivo for re-traduzido, somente as orações que mudaram desde a última tradução são enviadas ao provedor de tradução, e o resto é proveniente do banco de dados local.

Para traduzir um arquivo de propriedades Java para alemão e francês, usando o provedor do Google:

    $ translatomatic translate file --provider Google strings.properties de,fr

Isso criaria (ou substituiria) `strings_de.properties` e `strings_fr.properties` com propriedades traduzidas.

### Exibir sequências de caracteres de um pacote de recursos

Para ler e exibir o `store.description` e `store.name` propriedades de arquivos de recursos locais em inglês, alemão e francês:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### Extrair sequências de caracteres de arquivos-fonte

Para extrair cordas de arquivos de origem, use o `strings` comando, por exemplo,

    $ translatomatic strings file.rb

* * *

# # Convertendo arquivos

Translatomatic pode ser usado para converter arquivos de um formato para outro. Por exemplo, para converter um arquivo de propriedades Java em um arquivo de strings XCode:

    $ translatomatic convert strings.properties Localization.strings

* * *

# # Configuração

As configurações podem ser lidas e escritas usando o `config get` e `config set` comandos. Translatomatic usa um arquivo de configuração do usuário em `$HOME/.translatomatic/config.yml`, e, opcionalmente, um arquivo de configuração por projeto `$PROJECT_DIR/.translatomatic/config.yml`.

o `--user` e `--project` as opções podem ser usadas para indicar ao comando que lê ou escreva para o `user` ou `project` configuração.

As configurações são lidas das variáveis ​​de ambiente, do arquivo de configuração do usuário, do arquivo de configuração do projeto (se presente) e da linha de comando. O último valor encontrado prevalece sobre os valores lidos anteriormente.

Ao escrever para a configuração com o `config set` comando, o novo valor é gravado no arquivo de configuração do projeto quando executado dentro de um projeto contendo um arquivo de configuração translatomatic ou o arquivo de configuração do usuário se não houver nenhum arquivo de configuração do projeto.

### Translatomatic exemplos de configuração

Pôr `google_api_key` dentro do arquivo de configuração do usuário, use:

    $ translatomatic config set google_api_key value --user

Para definir um ou mais serviços de tradução para usar:

    $ translatomatic config set provider Microsoft,Yandex

Para definir uma lista padrão de localidades de destino:

    $ translatomatic config set target_locales en,de,es,fr,it

Com `target_locales` conjunto, os arquivos podem ser traduzidos sem especificar locais de destino no `translate file` comando.

    $ translatomatic translate file resources/strings.properties

Para exibir a configuração atual, execute:

    $ translatomatic config list

### Configuração de banco de dados

Por padrão, `translatomatic` usa um banco de dados sqlite3 em `$HOME/.translatomatic/translatomatic.sqlite3` para armazenar cadeias traduzidas. A configuração do banco de dados pode ser alterada criando um `database.yml` arquivo abaixo `$HOME/.translatomatic/database.yml` para o `production` ambiente, por exemplo,

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

# # Contribuindo

Os relatórios de erros e os pedidos de envio são bem-vindos no GitHub em https://github.com/smugglys/translatomatic. Este projeto pretende ser um espaço seguro e acolhedor para a colaboração, e os colaboradores devem aderir ao [Pacto de contribuinte](http://contributor-covenant.org) Código de conduta.

* * *

# # Licença

A gema está disponível como fonte aberta sob os termos do [Licença MIT](https://opensource.org/licenses/MIT).

* * *

# # Código de conduta

Todo mundo que interagir com as bases de códigos do projeto Translatomatic, rastreadores de problemas, salas de bate-papo e listas de endereços deverá seguir a [Código de conduta](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_Criado por Translatomatic 0.1.3 Thu, 01 Feb 2018 21:35:41 +1030 https://github.com/smugglys/translatomatic_
