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
      # this endpoint returns one translation per source text
      TRANSLATE_URL1 = "#{BASE_URL}/TranslateArray".freeze
      LIMITS_URL1 = [2000, 10_000].freeze # words, characters
      # this url returns multiple translations
      TRANSLATE_URL2 = "#{BASE_URL}/GetTranslationsArray".freeze
      LIMITS_URL2 = [10, 10_000].freeze # words, characters
      MAX_TRANSLATIONS = 10 # for URL2
      LANGUAGES_URL = "#{BASE_URL}/GetLanguagesForTranslate".freeze
      ARRAYS_NS = 'http://schemas.microsoft.com/2003/10/Serialization/Arrays'.freeze
      WEB_SERVICE_NS = 'http://schemas.datacontract.org/2004/07/Microsoft.MT.Web.Service.V2'.freeze

      def perform_translate(strings, from, to)
        # get multiple translations for strings with context, so we
        # can choose the best translation.
        strings_with_context = strings.select { |i| context?(i) }
        strings_without_context = strings.reject { |i| context?(i) }

        fetch_translation_array(strings_with_context, from, to, true)
        fetch_translation_array(strings_without_context, from, to, false)
      end

      # fetch translations for given strings
      def fetch_translation_array(strings, from, to, multiple)
        limit = multiple ? LIMITS_URL2 : LIMITS_URL1
        batcher(strings, max_count: limit[0], max_length: limit[1])
          .each_batch do |texts|
          translate_texts(texts, from, to, multiple)
        end
      end

      def translate_texts(texts, from, to, multiple)
        url = multiple ? TRANSLATE_URL2 : TRANSLATE_URL1
        headers = { 'Ocp-Apim-Subscription-Key' => @key }
        body = build_body_xml(texts, from, to, multiple)
        response = http_client.post(url, body,
                                    headers: headers,
                                    content_type: 'application/xml')
        add_translations_from_response(response, texts, multiple)
      end

      def add_translations_from_response(response, texts, multiple)
        doc = Nokogiri::XML(response.body)
        if multiple
          add_translations_from_response_multiple(doc, texts)
        else
          results = doc.search('//xmlns:TranslatedText').collect(&:content)
          texts.zip(results).each do |original, tr|
            add_translations(original, tr)
          end
        end
      end

      def add_translations_from_response_multiple(doc, texts)
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

      def xml_root(multiple)
        multiple ? 'GetTranslationsArray' : 'TranslateArray'
      end

      def build_body_xml(strings, from, to, multiple)
        root = xml_root(multiple) + 'Request'
        xml = Builder::XmlMarkup.new
        xml.tag!(root, 'xmlns:a' => ARRAYS_NS) do
          xml.AppId
          xml.From(from)
          build_options_xml(xml) if multiple
          build_texts_xml(xml, strings)
          xml.To(to)
          xml.MaxTranslations MAX_TRANSLATIONS if multiple
        end
      end

      def build_texts_xml(xml, strings)
        xml.Texts do
          strings.each do |string|
            xml.tag!('a:string', string)
          end
        end
      end

      def build_options_xml(xml)
        xml.tag!('Options', 'xmlns:o' => WEB_SERVICE_NS) do
          xml.tag!('o:IncludeMultipleMTAlternatives', 'true')
        end
      end

      def context?(text)
        text.is_a?(Translatomatic::Text) && text.context.present?
      end
    end
  end
end
