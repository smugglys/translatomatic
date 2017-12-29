module Translatomatic::TMX
  # Translation Memory Exchange document
  class Document

    # Create a new instance
    # @param [Array<TranslationUnit>] units A list of translation units
    # @param [Locale] source_locale Source locale
    # @param [String] origin Origin (o-tmx)
    # @return [Translatomatic::TMX::Document] a new TMX object
    def initialize(units, source_locale, origin)
      units = [units] unless units.kind_of?(Array)
      @units = units
      @source_locale = source_locale
      @origin = origin
    end

    # @return [String] An XML string
    def to_xml(options = {})
      builder = Nokogiri::XML::Builder.new do |xml|
        dtd = options[:dtd] || TMX_DTD
        xml.doc.create_internal_subset('tmx', nil, dtd)
        xml.tmx(version: "1.4") do
          xml.header(creationtool: "Translatomatic",
            creationtoolversion: Translatomatic::VERSION,
            datatype: "PlainText",
            segtype: "phrase",  # default segtype
            adminlang: @source_locale.to_s,
            srclang: @source_locale.to_s,
            "o-tmx": @origin
          )
          xml.body { tmx_body(xml) }
        end
      end
      builder.to_xml
    end

    # Create a TMX document from the given converter
    # @param [Array<Translatomatic::Model::Text>] texts List of texts
    # @return [Translatomatic::TMX::Document] TMX document
    def self.from_texts(texts)
      # group texts by from_text_id to create units
      # source_locale: use from_text.locale
      # origin: use text.translator
      origins = texts.collect { |i| i.translator }.compact.uniq
      raise t("tmx.multiple_origins") if origins.length > 1
      sources = texts.select { |i| i.from_text.nil? }
      source_locales = sources.collect { |i| i.locale }.uniq
      raise t("tmx.multiple_locales") if source_locales.length > 1
      units = units_from_texts(texts)

      return new(units, source_locales[0], origins[0])
    end

    def self.valid?(xml)
      options = Nokogiri::XML::ParseOptions::DTDVALID
      doc = Nokogiri::XML::Document.parse(xml, nil, nil, options)
      doc.internal_subset.validate(doc)
    end

    private

    class << self
      include Translatomatic::Util
    end

    TMX_DTD = "http://www.ttt.org/oscarstandards/tmx/tmx14.dtd"

    def tmx_body(xml)
      @units.each do |unit|
        xml.tu("segtype": unit.strings[0].type) do
          unit.strings.each do |string|
            xml.tuv("xml:lang": string.locale.to_s) do
              xml.seg string.value
            end
          end
        end
      end
    end

    # @return [Array<Translatomatic::TMX::TranslationUnit] translation unit list
    def self.units_from_texts(texts)
      # group texts by from_text_id
      texts_by_from_id = {}
      texts.each do |text|
        id = text.from_text_id || text.id
        list = (texts_by_from_id[id] ||= [])
        list << text
      end

      # create list of Translation Units
      texts_by_from_id.values.collect do |list|
        tmx_unit(list.uniq.collect { |i| string(i.value, i.locale) })
      end
    end

    def self.tmx_unit(strings)
      Translatomatic::TMX::TranslationUnit.new(strings)
    end

  end # class
end   # module
