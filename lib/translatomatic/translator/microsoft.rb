require 'builder'

module Translatomatic
  module Translator
    # Interface to the Microsoft translation API
    # @see https://www.microsoft.com/en-us/translator/translatorapi.aspx
    # @see http://docs.microsofttranslator.com/text-translate.html
    class Microsoft < Base
      define_option :microsoft_api_key,
                    desc: t('translator.microsoft_api_key'), use_env: true

      # Create a new Microsoft translator instance
      def initialize(options = {})
        super(options)
        @key = options[:microsoft_api_key] || ENV['MICROSOFT_API_KEY']
        raise t('translator.microsoft_key_required') if @key.nil?
      end

      # (see Base#languages)
      def languages
        @languages ||= fetch_languages
      end

      private

      BASE_URL = 'https://api.microsofttranslator.com/V2/Http.svc'.freeze
      TRANSLATE_ARRAY_1_URL = "#{BASE_URL}/TranslateArray".freeze
      TRANSLATE_ARRAY_N_URL = "#{BASE_URL}/GetTranslationsArray".freeze
      TRANSLATE_N_URL = "#{BASE_URL}/GetTranslations".freeze
      LANGUAGES_URL = "#{BASE_URL}/GetLanguagesForTranslate".freeze
      ARRAYS_NS = 'http://schemas.microsoft.com/2003/10/Serialization/Arrays'.freeze
      OPTS_NS = 'http://schemas.datacontract.org/2004/07/Microsoft.MT.Web.Service.V2'.freeze
      MAX_TRANSLATIONS = 10

      def perform_translate(strings, from, to)
        attempt_with_retries(3) do
          fetch_translation_array(strings, from, to, false)
        end
      end

      # fetch single translation or n translations for given strings
      def fetch_translation_array(strings, from, to, multiple = true)
        url = multiple ? TRANSLATE_ARRAY_N_URL : TRANSLATE_ARRAY_1_URL
        body = build_body_xml(strings, from, to, multiple)
        headers = { 'Ocp-Apim-Subscription-Key' => @key }
        log.debug("#{name} request: #{url}, body: #{body}")

        response = http_client.post(url, body,
                                    headers: headers,
                                    content_type: 'application/xml')
        log.debug("#{name} response: #{response.body}")
        doc = Nokogiri::XML(response.body)
        doc.search('//xmlns:TranslatedText').collect(&:content)
      end

      def fetch_translation(string, from, to)
        url = TRANSLATE_N_URL
        query = {
          appid: '',
          text: string,
          from: from,
          to: to,
          maxTranslations: MAX_TRANSLATIONS
        }
        headers = { 'Ocp-Apim-Subscription-Key' => @key }
        body = build_translation_options_xml
        log.debug("#{name} request: #{url}, body: #{body}")

        response = http_client.post(url, body,
                                    query: query,
                                    headers: headers,
                                    content_type: 'application/xml')
        log.debug("#{name} response: #{response.body}")
        doc = Nokogiri::XML(response.body)
        doc.search('//xmlns:TranslatedText').collect(&:content)
      end

      def fetch_languages
        # this request redirects to a html page
        headers = { 'Ocp-Apim-Subscription-Key' => @key }
        query = { 'appid' => '' }
        response = http_client.get(LANGUAGES_URL, query, headers: headers)
        doc = Nokogiri::XML(response.body)
        doc.search('//xmlns:string').collect(&:content)
      end

      def build_body_xml(strings, from, to, multiple)
        root = (multiple ? 'GetTranslations' : 'Translate') + 'ArrayRequest'
        xml = Builder::XmlMarkup.new
        xml.tag!(root, 'xmlns:a' => ARRAYS_NS) do
          xml.AppId
          xml.From(from)
          build_options_xml(xml) if multiple
          xml.Texts do
            strings.each do |string|
              xml.tag!('a:string', string)
            end
          end
          xml.To(to)
          xml.MaxTranslations MAX_TRANSLATIONS if multiple
        end
      end

      def build_translation_options_xml
        xml = Builder::XmlMarkup.new
        xml.tag!('TranslateOptions', 'xmlns' => OPTS_NS) do
          xml.IncludeMultipleMTAlternatives 'true'
        end
      end

      def build_options_xml(xml)
        xml.tag!('Options', 'xmlns:o' => OPTS_NS) do
          # this option seems to be required to return multiple matches
          xml.tag!('o:IncludeMultipleMTAlternatives', 'true')
        end
      end
    end
  end
end
