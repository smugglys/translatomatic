module Translatomatic::TMX
  # Translation Memory Exchange document
  class Document

    # Create a new instance
    # @param [Array<TranslationUnit>] A list of translation units
    # @param [Locale] Source locale
    # @return A new TMX object
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
            segtype: "sentence",  # TODO: or "phrase"
            adminlang: @source_locale.to_s,
            srclang: @source_locale.to_s,
            "o-tmx": @origin
          )
          xml.body do
            @units.each do |unit|
              xml.tu do
                unit.locale_strings.each do |locale_string|
                  xml.tuv("xml:lang" => locale_string.locale.to_s) do
                    xml.seg locale_string.value
                  end
                end
              end
            end
          end
        end
      end
      builder.to_xml
    end

    # Create a TMX document from the given converter
    # @param [Array<Translatomatic::Model::Text>] List of texts
    # @return [Translatomatic::TMX::Document] TMX document
    def self.from_texts(texts)
      # group texts by from_text_id to create units
      # source_locale: use from_text.locale
      # origin: use text.translator
      origins = texts.collect { |i| i.translator }.compact.uniq
      raise "Multiple origins in texts" if origins.length > 1
      sources = texts.select { |i| i.from_text.nil? }
      source_locales = sources.collect { |i| i.locale }.uniq
      raise "Multiple source locales in texts" if source_locales.length > 1
      units = units_from_texts(texts)

      return new(units, source_locales[0], origins[0])
    end

    def self.valid?(xml)
      options = Nokogiri::XML::ParseOptions::DTDVALID
      doc = Nokogiri::XML::Document.parse(xml, nil, nil, options)
      doc.internal_subset.validate(doc)
    end

    private

    TMX_DTD = "http://www.ttt.org/oscarstandards/tmx/tmx14.dtd"

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
        tmx_unit(list.uniq.collect { |i| locale_string(i) })
      end
    end

    def self.tmx_unit(locale_strings)
      Translatomatic::TMX::TranslationUnit.new(locale_strings)
    end

    def self.locale_string(text)
      Translatomatic::TMX::LocaleString.new(text.value, text.locale)
    end

  end # class
end   # module
