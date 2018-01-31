require 'builder'

module Translatomatic
  module Provider
    # Interface to the Microsoft translation API
    # @see https://www.microsoft.com/en-us/translator/translatorapi.aspx
    # @see http://docs.microsofttranslator.com/text-translate.html
    class Microsoft < Base
      define_option :microsoft_api_key,
                    desc: t('provider.microsoft.api_key'), use_env: true

      # (see Base.supports_multiple_translations?)
      def self.supports_multiple_translations?
        true
      end

      # (see Base.supports_no_translate_html?)
      def self.supports_no_translate_html?
        true
      end

      # Create a new Microsoft provider instance
      def initialize(options = {})
        super(options)
        @key = options[:microsoft_api_key] || ENV['MICROSOFT_API_KEY']
        raise t('provider.microsoft.key_required') if @key.nil?
      end

      # (see Base#languages)
      def languages
        @languages ||= fetch_languages
      end

      private

      BASE_URL = 'https://api.microsofttranslator.com/V2/Http.svc'.freeze
      TRANSLATE_URL = "#{BASE_URL}/GetTranslationsArray".freeze
      LANGUAGES_URL = "#{BASE_URL}/GetLanguagesForTranslate".freeze
      ARRAYS_NS = 'http://schemas.microsoft.com/2003/10/Serialization/Arrays'.freeze
      OPTS_NS = 'http://schemas.datacontract.org/2004/07/Microsoft.MT.Web.Service.V2'.freeze
      MAX_TRANSLATIONS = 10
      MAX_TEXTS_PER_REQUEST = 10

      def perform_translate(strings, from, to)
        fetch_translation_array(strings, from, to)
      end

      # fetch translations for given strings
      def fetch_translation_array(strings, from, to)
        strings.each_slice(MAX_TEXTS_PER_REQUEST) do |texts|
          translate_texts(texts, from, to)
        end
      end

      def translate_texts(texts, from, to)
        url = TRANSLATE_URL
        headers = { 'Ocp-Apim-Subscription-Key' => @key }
        body = build_body_xml(texts, from, to)
        response = http_client.post(url, body,
                                    headers: headers,
                                    content_type: 'application/xml')
        add_translations_from_response(response, texts)
      end

      def add_translations_from_response(response, texts)
        doc = Nokogiri::XML(response.body)
        # there should be one GetTranslationsResponse for each string
        responses = doc.search('//xmlns:GetTranslationsResponse')
        texts.zip(responses).each do |original, tr|
          results = tr.search('TranslatedText').collect(&:content)
          add_translations(original, results)
        end
      end

      def fetch_languages
        # this request redirects to a html page
        headers = { 'Ocp-Apim-Subscription-Key' => @key }
        query = { 'appid' => '' }
        response = http_client.get(LANGUAGES_URL, query, headers: headers)
        log.debug("#{name} response: #{response.body}")
        doc = Nokogiri::XML(response.body)
        doc.search('//xmlns:string').collect(&:content)
      end

      def build_body_xml(strings, from, to)
        root = 'GetTranslationsArrayRequest'
        xml = Builder::XmlMarkup.new
        xml.tag!(root, 'xmlns:a' => ARRAYS_NS) do
          xml.AppId
          xml.From(from)
          build_options_xml(xml)
          xml.Texts do
            strings.each do |string|
              xml.tag!('a:string', string)
            end
          end
          xml.To(to)
          xml.MaxTranslations MAX_TRANSLATIONS
        end
      end

      def build_options_xml(xml)
        xml.tag!('Options', 'xmlns:o' => OPTS_NS) do
          xml.tag!('o:IncludeMultipleMTAlternatives', 'true')
        end
      end
    end
  end
end
