module Translatomatic
  # Translates strings from one language to another
  class Translator
    def initialize(options = {})
      @listener = options[:listener]
      @providers = resolve_providers(options)
      raise t('translator.provider_required') if @providers.empty?
      @providers.each { |i| i.listener = @listener } if @listener

      # use database by default if we're connected to a database
      @use_db = !options[:no_database] && ActiveRecord::Base.connected?
      log.debug(t('translator.database_disabled')) unless @use_db

      @db_translations = []
      @stats = Translatomatic::TranslationStats.new
    end

    # Translate strings to a target locale
    # @param [Array<Translatomatic::String>] Strings to translate
    # @param [Locale] Target locale
    def translate(strings, _locale)
      strings = [strings] unless strings.is_a?(Array)
      strings
    end

    private

    def resolve_providers(options)
      Translatomatic::Provider.resolve(options[:provider], options)
    end
  end
end
