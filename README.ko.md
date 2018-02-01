[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# 해설자

한 언어에서 다른 언어로 또는 한 형식에서 다른 형식으로 텍스트 파일을 변환합니다. 현재 지원되는 파일 형식은 다음과 같습니다.

| 파일 형식 | 확장 |
| --- | --- |
| [속성](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| Windows 리소스 파일 | `.resw, .resx` |
| [속성 목록](https://en.wikipedia.org/wiki/Property_list) (OSX plist) | `.plist` |
| [PO 파일](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [XCode 문자열](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [YAML](http://yaml.org/) | `.yaml` |
| 자막 | `.srt, .ass, .ssa` |
| HTML | `.html, .htm, .shtml` |
| XML | `.xml` |
| [가격 인하](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| 텍스트 파일 | `.txt` |
| CSV 파일 | `.csv` |

다음 번역 공급자는 Translatomatic와 함께 사용할 수 있습니다.

- [구글](https://cloud.google.com/translate/)
- [마이크로 소프트](https://www.microsoft.com/en-us/translator/translatorapi.aspx)
- [얀덱스](https://tech.yandex.com/translate/)
- [내 기억](https://mymemory.translated.net/doc/)
- [열렬히](http://www.frengly.com/api)

번역 된 문자열은 데이터베이스에 저장 하 고 다시.

* * *

# # 설치

이 줄을 응용 프로그램에 추가하십시오. `Gemfile`:

`ruby
gem 'translatomatic'
`

그리고 실행:

    $ bundle

또는으로 그것을 너 자신 설치:

    $ gem install translatomatic

* * *

# # 사용

이 젬은 다음과 같은 실행 파일을 제공합니다. `translatomatic`. 그만큼 `translatomatic` 명령에는 여러 가지 기능이 있지만 여기에 모두 설명 된 것은 아닙니다. 사용 가능한 명령 및 옵션에 대한 도움말은 다음을 실행하십시오.

    $ translatomatic help

그리고에 대 한 도움말을 명령, 실행:

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

# # 설치

사용 가능한 번역 업체 및 옵션이 있는지 확인하십시오. `providers` 명령:

    $ translatomatic providers

옵션은 명령 행, 환경 변수 또는 변환의 구성 파일에 지정할 수 있습니다. 구성 파일은 translatomatic의 내부를 사용하여 수정할 수 있습니다 `config` 명령. 사용 가능한 모든 구성 설정을 나열하려면 다음을 사용하십시오.

    $ translatomatic config list
    $ translatomatic config describe

옵션은 사용자 수준 또는 프로젝트 수준에서 설정할 수 있습니다. 자세한 내용은 아래의 구성 섹션을 참조하십시오.

* * *

# # 파일을 번역

파일을 번역 할 때, `translatomatic` 한 번에 한 문장 또는 한 문장의 텍스트를 번역합니다. 파일을 다시 번역하면 마지막 번역 이후 변경된 문장 만 번역 공급자에게 보내지고 나머지는 로컬 데이터베이스에서 제공됩니다.

자바 속성 파일을 독일어와 프랑스어 구글 공급자를 사용 하 여 번역:

    $ translatomatic translate file --provider Google strings.properties de,fr

이것은 (또는 덮어 쓰기) `strings_de.properties` 과 `strings_fr.properties` 번역 된 속성.

### 리소스 번들에서 문자열 표시

해당 내용을 읽고 표시하려면 `store.description` 과 `store.name` 영어, 독일어 및 프랑스어로 된 로컬 리소스 파일의 등록 정보 :

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### 소스 파일에서 문자열을 추출

소스 파일에서 문자열을 추출하려면 `strings` 명령, 예.

    $ translatomatic strings file.rb

* * *

# # 파일 변환

Translatomatic은 한 형식에서 다른 형식으로 파일을 변환하는 데 사용할 수 있습니다. 예를 들어, Java 특성 파일을 XCode 문자열 파일로 변환하려면 다음을 수행하십시오.

    $ translatomatic convert strings.properties Localization.strings

* * *

# # 구성

구성 설정은 다음을 사용하여 읽고 쓸 수 있습니다. `config get` 과 `config set` 명령. Translatomatic은에서 사용자 구성 파일을 사용합니다. `$HOME/.translatomatic/config.yml`, 그리고 선택적으로 프로젝트 당 설정 파일 `$PROJECT_DIR/.translatomatic/config.yml`.

그만큼 `--user` 과 `--project` 옵션을 사용하여 명령에 명령을 읽거나 쓰도록 지시 할 수 있습니다. `user` 또는 `project` 구성.

구성 설정은 환경 변수, 사용자 구성 파일, 프로젝트 구성 파일 (있는 경우) 및 명령 행에서 읽습니다. 발견 된 마지막 값은 이전에 읽은 값보다 우선합니다.

구성을 사용하여 `config set` 명령의 경우 새 값은 변환 구성 파일을 포함하는 프로젝트 내에서 실행될 때 프로젝트 구성 파일에 기록되거나 프로젝트 구성 파일이없는 경우 사용자 구성 파일에 기록됩니다.

### Translatomatic 구성 예

설정 `google_api_key` 사용자 구성 파일 내에서 다음을 사용하십시오.

    $ translatomatic config set google_api_key value --user

설정 하려면 하나 이상의 번역 서비스를 사용 하 여:

    $ translatomatic config set provider Microsoft,Yandex

설정 하려면 대상 로케일의 기본 목록:

    $ translatomatic config set target_locales en,de,es,fr,it

와 `target_locales` 설정하면 대상 로케일을 지정하지 않고도 파일을 번역 할 수 있습니다. `translate file` 명령.

    $ translatomatic translate file resources/strings.properties

현재 구성을 표시 하려면 실행:

    $ translatomatic config list

### 데이터베이스 구성

기본적으로, `translatomatic` 에서 sqlite3 데이터베이스 사용 `$HOME/.translatomatic/translatomatic.sqlite3` 번역 된 문자열을 저장합니다. 데이터베이스 구성은 다음을 작성하여 변경할 수 있습니다. `database.yml` 밑에있는 파일 `$HOME/.translatomatic/database.yml` 그 `production` 환경, 예.

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

# # 기여

GitHub (https://github.com/smugglys/translatomatic)에서 버그보고 및 요청을 환영합니다. 이 프로젝트는 공동 작업을위한 안전하고 환영할만한 공간으로 만들어졌으며 참여자는 [참가자 언약](http://contributor-covenant.org) 행동 규범.

* * *

# # 라이센스

이 젬은 오픈 소스로 이용 가능합니다. [MIT 라이센스](https://opensource.org/licenses/MIT).

* * *

# # 강령

Translatomatic 프로젝트의 코드베이스, 이슈 트래커, 대화방 및 메일 링리스트와 상호 작용하는 모든 사람들은 [윤리 강령](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md).

_만든 Translatomatic 0.1.3 Thu, 01 Feb 2018 21:35:41 +1030 https://github.com/smugglys/translatomatic_
