[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

다른 한 형식에서 다른 하나의 언어에서 텍스트 파일을 변환합니다. 다음 파일 형식이 현재 지원 됩니다.

| 파일 형식 | 확장 |
| --- | --- |
| [성](https://en.wikipedia.org/wiki/.properties) | `.properties` |
| Windows 리소스 파일 | `.resw, .resx` |
| [객실 목록](https://en.wikipedia.org/wiki/Property_list) (OSX plist) | `.plist` |
| [PO 파일](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) | `.po, .pot` |
| [XCode 문자열](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) | `.strings` |
| [YAML](http://yaml.org/) | `.yaml` |
| 자막 | `.srt, .ass, .ssa` |
| HTML | `.html, .htm, .shtml` |
| XML | `.xml` |
| [Markdown](https://en.wikipedia.org/wiki/Markdown) | `.md` |
| 텍스트 파일 | `.txt` |
| CSV 파일 | `.csv` |

다음 번역 Api Translatomatic와 함께 사용할 수 있습니다.

- [구글](https://cloud.google.com/translate/)
- [마이크로 소프트](https://www.microsoft.com/en-us/provider/providerapi.aspx)
- [Yandex](https://tech.yandex.com/translate/)
- [MyMemory](https://mymemory.translated.net/doc/)
- [Frengly](http://www.frengly.com/api)

번역된 문자열 데이터베이스에서 저장 및 재사용 가능합니다.

* * *

# # 설치

이 줄을 추가하는 응용 프로그램 `Gemfile`:

`ruby
gem 'translatomatic'
`

한 후 실행하기:

    $ bundle

거나 설치로서 자신을:

    $ gem install translatomatic

* * *

# # 사용

라는 실행 파일을 제공 하는이 보석 `translatomatic`니다. 는 `translatomatic` 명령 기능, 모두는 여기에 설명 되어 있다. 에 대 한 도움말 사용 가능한 명령 및 옵션을 실행 합니다.

    $ translatomatic help

그리고에 대 한 도움말을 명령, 실행:

    $ translatomatic translate help
    $ translatomatic translate help file

* * *

# # 설치

사용 가능한 번역 서비스와 옵션에 대 한 확인은 `services` 명령:

    $ translatomatic services

환경 변수, 또는 translatomatic의 구성 파일에서 명령줄에 옵션을 지정할 수 있습니다. Translatomatic를 사용 하 여 파일을 수정할 수 있습니다 구성의 내부 `config` 명령입니다. 모든 사용 가능한 구성 설정, 사용:

    $ translatomatic config list
    $ translatomatic config describe

옵션은 사용자 수준 또는 프로젝트 수준에서 설정할 수 있습니다. 또한 자세한 내용은 아래의 구성 섹션을 참조.

* * *

# # 파일을 번역

파일을 변환할 때 `translatomatic` 번역 텍스트나 문장이나 문구를 시간이다. 파일은 다시 번역 하는 경우 마지막 번역 이후 변경 된 유일한 문장 번역기, 전송 됩니다 그리고 나머지는 로컬 데이터베이스에서 공급.

자바 속성 파일을 독일어와 프랑스어 구글 번역기를 사용 하 여 번역:

    $ translatomatic translate file --provider Google strings.properties de,fr

이들(또는 덮어쓰기) `strings_de.properties` 고 `strings_fr.properties` 와 속성을 변환.

### 문자열을 표시하는 리소스에 번들

를 읽고 표시 `store.description` 고 `store.name` 속성에서 지역 자원에서 파일을 영어,독일어,프랑스:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### 추출 문서는 원본 파일

사용 하는 소스 파일에서 문자열을 추출 하는 `strings` 예를 들어, 명령

    $ translatomatic strings file.rb

* * *

# # 파일 변환

Translatomatic는 한 형식에서 다른 파일을 변환에 사용할 수 있습니다. 예를 들어 자바로 변환 하는 XCode에 속성 파일 문자열 파일:

    $ translatomatic convert strings.properties Localization.strings

* * *

# # 구성

Translatomatic는 사용자 구성 파일에 `$HOME/.translatomatic/config.yml`그리고 선택적으로 한 프로젝트 구성 파일 당 `$PROJECT_DIR/.translatomatic/config.yml`니다. 는e `translatomatic config set` 명령은 translatomatic 구성 파일을 포함 하는 프로젝트 내에서 실행 될 때 프로젝트 수준 구성에서 작동 합니다.렇지 않으면 사용자 수준 구성 파일이 변경 됩니다. The `--context` 옵션 지정을 사용할 수 있습니다. `user` 또는 `project` 레벨 구성입니다. 구성 옵션의 유효 값 읽기 환경, 사용자 수준 구성 파일, 프로젝트 수준 구성 파일 (있는 경우)에서 및 명령줄에서 의해 결정 됩니다. 마지막 값 발견 이전에 읽은 값 보다 우선 합니다.

### Translatomatic 구성 예

설정 하려면 `google_api_key` 사용자 구성 파일 내에서 사용 합니다.

    $ translatomatic config set google_api_key value --context user

설정 하려면 하나 이상의 번역 서비스를 사용 하 여:

    $ translatomatic config set provider Microsoft,Yandex

2 차 번역 번역 오류가 발생 하는 첫 번째 선택을 사용 하는 경우 경우에 사용 됩니다.

설정 하려면 대상 로케일의 기본 목록:

    $ translatomatic config set target_locales en,de,es,fr,it

와 함께 `target_locales` 설정, 파일 번역 될 수 있는 대상 로케일을 지정 하지 않고는 `translate file` 명령입니다.

    $ translatomatic translate file resources/strings.properties

현재 구성을 표시 하려면 실행

    $ translatomatic config list

### 데이터베이스 구성

기본적으로, `translatomatic` 사용 sqlite3 데이터베이스에 `$HOME/.translatomatic/translatomatic.sqlite3` 를 저장하는 번역된 문자열이다. 번역 데이터베이스에 저장 하기와 같은 설치 적절 한 데이터베이스 어댑터 있어야 합니다 `sqlite3` 보석입니다. Translatomatic는 데이터베이스 어댑터를 자동으로 설치 되지 않습니다. 데이터베이스 구성을 생성 하 여 변경 수는 `database.yml` 에서 파일 `$HOME/.translatomatic/database.yml` 대 `production` 환경,예를 들어,

    production:
      adapter: mysql2
      host: db.example.com
      database: translatomatic
      pool: 5
      encoding: utf8
      username: username
      password: password

* * *

# # 기여

버그 보고 및 풀 요청에 오신 것을 환영 합니다 GitHub 에 https://github.com/smugglys/translatomatic 니다. 이 프로젝트 수입한 것이 안전하고,공간에 대한 협력,그리고 참가자는 예상을 준수하 [기여자가 언약](http://contributor-covenant.org) 의 코드를 실시하고 있습니다.

* * *

# # 라이센스

보석으로 사용할 수 있는 오픈 소스에서의 약관 [MIT 라이센스](https://opensource.org/licenses/MIT)니다.

* * *

# # 강령

모든 사람과 상호 작용 Translatomatic 프로젝트의 지원,문제 trackers,대화방 및 메일링 리스트를 수행 할 것으로 예상된 [윤리 강령](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md)니다.

_Translatomatic 0.1.2 Sat, 06 Jan 2018 22:56:24 +1030에 의해 만들어진_
