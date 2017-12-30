[![Documentation](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/translatomatic)[![Gem Version](https://badge.fury.io/rb/translatomatic.svg)](https://badge.fury.io/rb/translatomatic)[![Build Status](https://travis-ci.org/smugglys/translatomatic.svg?branch=master)](https://travis-ci.org/smugglys/translatomatic)[![Code Climate](https://codeclimate.com/github/smugglys/translatomatic.svg)](https://codeclimate.com/github/smugglys/translatomatic)

# Translatomatic

번역 텍스트 파일로서 다른 하나의 언어입니다. 다음 파일 형식 현재 지원되:

- [성](https://en.wikipedia.org/wiki/.properties)
- RESW(Windows resources 파일)
- [객실 목록](https://en.wikipedia.org/wiki/Property_list) (OSX plist)
- HTML
- XML
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

명령줄 인터페이스를 위한 번역 기능이 `translatomatic`니다. 에 대한 도움말을 사용할 수 있는 옵션을 실행하기:

    $ translatomatic help

### 번역 파일

`translatomatic` 번역 텍스트나 문장이나 문구를 시간이다. 면 파일을 다시 번역,만 문장이 있는 변경에 보내는 번역사,그리고 나머지 부분에서 공급되는 로컬 데이터베이스입니다.

목록을 사용할 수 있는 번역 서비스와 옵션:

    $ translatomatic translators

번역 Java properties 파일을 독일어,프랑스:

    $ translatomatic translate resources/strings.properties de fr

이들(또는 덮어쓰기) `strings_de.properties` 고 `strings_fr.properties`니다.

### 추출 문서는 원본 파일

추출 문자열을 일부 소스에서 파일을 사용하여 추출물 명령,예를 들어,

    $ translatomatic strings file.rb

### 문자열을 표시하는 리소스에 번들

를 읽고 표시 `store.description` 고 `store.name` 속성에서 지역 자원에서 파일을 영어,독일어,프랑스:

    $ translatomatic display --locales=en,de,fr \
        resources/strings.properties store.description store.name

## 구성

기본적으로, `translatomatic` 사용 sqlite3 데이터베이스에 `$HOME/.translatomatic/translatomatic.sqlite3` 를 저장하는 번역된 문자열이다. 데이터베이스에 의해 변경 될 수 있습 만들기 `database.yml` 에서 파일 `$HOME/.translatomatic/database.yml` 대 `production` 환경,예를 들어,

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

모든 사람과 상호 작용 Translatomatic 프로젝트의 지원,문제 trackers,대화방 및 메일링 리스트를 수행 할 것으로 예상된 [code of conduct](https://github.com/smugglys/translatomatic/blob/master/CODE_OF_CONDUCT.md)니다.

_Created by Translatomatic 0.1.1 Sat, 30 Dec 2017 22:53:45 +1030_
