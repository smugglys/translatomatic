require 'builder'

module Translatomatic
  module Translator
    # Interface to the Microsoft translation API
    # @see https://www.microsoft.com/en-us/translator/translatorapi.aspx
    class Microsoft < Base
      define_options(
        { name: :microsoft_api_key, desc: t('translator.microsoft_api_key'),
          use_env: true }
      )

      # Create a new Microsoft translator instance
      def initialize(options = {})
        super(options)
        @key = options[:microsoft_api_key] || ENV['MICROSOFT_API_KEY']
        raise t('translator.microsoft_key_required') if @key.nil?
      end

      # (see Translatomatic::Translator::Base#languages)
      def languages
        @languages ||= fetch_languages
      end

      private

      BASE_URL = 'https://api.microsofttranslator.com/V2/Http.svc'.freeze
      TRANSLATE_URL = "#{BASE_URL}/TranslateArray".freeze
      LANGUAGES_URL = "#{BASE_URL}/GetLanguagesForTranslate".freeze
      ARRAYS_NS = 'http://schemas.microsoft.com/2003/10/Serialization/Arrays'.freeze

      def perform_translate(strings, from, to)
        attempt_with_retries(3) do
          fetch_translations(strings, from, to)
        end
      end

      def fetch_translations(strings, from, to)
        request = Translatomatic::HTTPRequest.new(TRANSLATE_URL)
        headers = { 'Ocp-Apim-Subscription-Key' => @key }
        body = build_body(strings, from, to)
        response = request.post(body,
                                headers: headers,
                                content_type: 'application/xml')
        doc = Nokogiri::XML(response.body)
        doc.search('//xmlns:TranslatedText').collect(&:content)
      end

      def fetch_languages
        # this request redirects to a html page
        request = Translatomatic::HTTPRequest.new(LANGUAGES_URL)
        headers = { 'Ocp-Apim-Subscription-Key' => @key }
        response = request.get({ 'appid' => '' }, headers: headers)
        doc = Nokogiri::XML(response.body)
        doc.search('//xmlns:string').collect(&:content)
      end

      def build_body(strings, from, to)
        xml = Builder::XmlMarkup.new
        xml.tag!('TranslateArrayRequest', 'xmlns:a' => ARRAYS_NS) do
          xml.AppId
          xml.From(from)
          xml.Texts do
            strings.each do |string|
              xml.tag!('a:string', string)
            end
          end
          xml.To(to)
        end
      end
    end
  end
end
