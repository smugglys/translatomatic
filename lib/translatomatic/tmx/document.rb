module Translatomatic
  module TMX
    # Translation Memory Exchange document
    class Document
      # Create a new instance
      # @param units [Array<TranslationUnit>] A list of translation units
      # @param source_locale [Locale] Source locale
      # @return [Translatomatic::TMX::Document] a new TMX object
      def initialize(units, source_locale)
        units = [units] unless units.is_a?(Array)
        @units = units
        @source_locale = source_locale
      end

      # @return [String] An XML string
      def to_xml(options = {})
        builder = Nokogiri::XML::Builder.new do |xml|
          dtd = options[:dtd] || TMX_DTD
          xml.doc.create_internal_subset('tmx', nil, dtd)
          xml.tmx(version: '1.4') do
            xml.header(tmx_header)
            xml.body { tmx_body(xml) }
          end
        end
        builder.to_xml
      end

      # Create a TMX document from the given converter
      # @param texts [Array<Translatomatic::Model::Text>] List of texts
      # @return [Translatomatic::TMX::Document] TMX document
      def self.from_texts(texts)
        # group texts by from_text_id to create units
        # source_locale: use from_text.locale
        # origin: use text.translator
        sources = texts.select { |i| i.from_text.nil? }
        source_locales = sources.collect(&:locale).uniq
        raise t('tmx.multiple_locales') if source_locales.length > 1
        units = units_from_texts(texts)

        new(units, source_locales[0])
      end

      def self.valid?(xml)
        options = Nokogiri::XML::ParseOptions::DTDVALID
        doc = Nokogiri::XML::Document.parse(xml, nil, nil, options)
        doc.internal_subset.validate(doc)
      end

      private

      class << self
        include Translatomatic::Util

        private

        # @return [Array<Translatomatic::TMX::TranslationUnit]
        #   translation unit list
        def units_from_texts(texts)
          # group texts by from_text_id
          texts_by_from_id = {}
          texts.each do |text|
            id = text.from_text_id || text.id
            list = (texts_by_from_id[id] ||= [])
            list << text
          end

          # create list of Translation Units
          texts_by_from_id.values.collect do |list|
            strings = list.uniq.collect { |i| string(i.value, i.locale) }
            tmx_unit(strings)
          end
        end

        def tmx_unit(strings)
          Translatomatic::TMX::TranslationUnit.new(strings)
        end
      end

      TMX_DTD = 'http://www.ttt.org/oscarstandards/tmx/tmx14.dtd'.freeze
      DEFAULT_OTMF = 'Translatomatic'.freeze

      def tmx_header
        {
          creationtool: 'Translatomatic',
          creationtoolversion: Translatomatic::VERSION,
          datatype: 'PlainText',
          segtype: 'phrase', # default segtype
          adminlang: @source_locale.to_s,
          srclang: @source_locale.to_s,
          'o-tmf' => DEFAULT_OTMF
        }
      end

      def tmx_body(xml)
        @units.each do |unit|
          xml.tu('segtype' => unit.strings[0].type) do
            unit.strings.each do |string|
              xml.tuv('xml:lang' => string.locale.to_s) do
                xml.seg string.value
              end
            end
          end
        end
      end
    end
  end
end
