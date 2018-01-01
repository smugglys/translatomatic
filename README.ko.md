[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

번역 텍스트 파일로서 다른 하나의 언어입니다. 다음 파일 형식 현재 지원되:

- [성](https://en.wikipedia.org/wiki/.properties)
- RESW(Windows resources 파일)
- [객실 목록](https://en.wikipedia.org/wiki/Property_list) (OSX plist)
- HTML
- XML
- [Markdown](https://en.wikipedia.org/wiki/Markdown)
- [XCode 문자열](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html)
- [YAML](http://yaml.org/)
- 텍스트 파일

번역된 문자열 데이터베이스에서 저장 및 재사용 가능합니다.

## 설치

이 줄을 추가하는 응용 프로그램 `Gemfile`:

`ruby
gem 'translatomatic'
`

한 후 실행하기:

    $ bundle

거나 설치로서 자신을:

    $ gem install translatomatic

## 사용법

라는 실행 파일을 제공 하는이 보석 `translatomatic`니다는he `translatomatic` 명령 기능, 모두는 여기에 설명 되어 있다. 에 대 한 도움말 사용 가능한 명령 및 옵션을 실행 합니다.

    $ translatomatic help

그리고는 하위에 도움, 실행:

    $ translatomatic translate help
    $ translatomatic translate help file

### 번역 파일

파일을 변환할 때 `translatomatic` 번역 텍스트나 문장이나 문구를 시간이다. If a file is re-translated,파일은 다시 번역 하는 경우 마지막 번역 이후 변경 된 유일한 문장 번역기, 전송 됩니다 그리고 나머지는 로컬 데이터베이스에서 공급.

목록을 사용할 수 있는 번역 서비스와 옵션:

    $ translatomatic list

번역 Java properties 파일을 독일어,프랑스:

    $ translatomatic translate file resources/strings.properties de,fr

이들(또는 덮어쓰기) `strings_de.properties` 고 `strings_fr.properties`니다.

### 문자열을 표시하는 리소스에 번들

를 읽고 표시 `store.description` 고 `store.name` 속성에서 지역 자원에서 파일을 영어,독일어,프랑스:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

### 추출 문서는 원본 파일

추출 문자열을 일부 소스에서 파일을 사용하여 추출물 명령,예를 들어,

    $ translatomatic strings file.rb

## 구성

### Translatomatic 구성 파일

많은 커맨드 라인 옵션 Translatomatic를 사용 하 여 구성할 수 있습니다의 내부 `config` 명령입니다. 예를 들어 설정 하려면 대상 번역 로케일의 기본 목록, 실행 합니다.

    $ translatomatic config set target_locales en,de,es,fr,it

와 함께 `target_locales` 설정, 파일 번역 될 수 있는 대상 로케일을 지정 하지 않고는 `translate file` 명령입니다.

    $ translatomatic translate file resources/strings.properties

현재 구성을 표시 하려면 실행

    $ translatomatic config list

### 데이터베이스 구성

기본적으로, `translatomatic` 사용 sqlite3 데이터베이스에 `$HOME/.translatomatic/translatomatic.sqlite3` 를 저장하는 번역된 문자열이다. To store tr번역 데이터베이스에 저장 하기와 같은 설치 적절 한 데이터베이스 어댑터 있어야 합니다`sqlite3` 보석입니다. Translatomatic는 데이터베이스 어댑터를 자동으로 설치 되지 않습니다. 데이터베이스 구성을 생성 하 여 변경 수는 `database.yml` 에서 파일 `$HOME/.translatomatic/database.yml` 대 `production` 환경,예를 들어,

    production:
      adapter: mysql2
      host: db.example.com
      database: translatomatic
      pool: 5
      encoding: utf8
      username: username
      password: password

## 에 기여

버그 보고 및 풀 요청에 오신 것을 환영 합니다 GitHub 에 https://github.com/smugglys/translatomatic 니다. 이 프로젝트 수입한 것이 안전하고,공간에 대한 협력,그리고 참가자는 예상을 준수하 [기여자가 언약](http://contributor-covenant.org) 의 코드를 실시하고 있습니다.

## 라이선스

보석으로 사용할 수 있는 오픈 소스에서의 약관 [MIT 라이센스](https://opensource.org/licenses/MIT)니다.

## Code of Conduct

모든 사람과 상호 작용 Translatomatic 프로젝트의 지원,문제 trackers,대화방 및 메일링 리스트를 수행 할 것으로 예상된 [윤리 강령](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md)니다.

_Created by Translatomatic 0.1.1 Sun, 31 Dec 2017 17:27:47 +1030_