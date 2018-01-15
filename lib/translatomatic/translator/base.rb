
module Translatomatic
  module Translator
    # Base class for interfaces to translation APIs
    # @abstract
    class Base
      include Translatomatic::DefineOptions

      # Listener for translation events
      attr_accessor :listener

      def initialize(options = {})
        @listener = options[:listener]
      end

      # @return [String] The name of this translator.
      def name
        self.class.name.demodulize
      end

      # @return [Array<String>] A list of languages supported by this translator.
      def languages
        []
      end

      # Translate strings from one locale to another
      # @param strings [Array<String>] A list of strings to translate.
      # @param from [String, Translatomatic::Locale] The locale of the given strings.
      # @param to [String, Translatomatic::Locale] The locale to translate to.
      # @return [Array<String>] Translated strings
      def translate(strings, from, to)
        @updated_listener = false
        strings = [strings] unless strings.is_a?(Array)
        from = locale(from)
        to = locale(to)
        return strings if from.language == to.language
        translated = perform_translate(strings, from, to)
        update_translated(translated) unless @updated_listener
        translated
      end

      private

      include Translatomatic::Util

      TRANSLATION_RETRIES = 3

      # Fetch translations for the given strings, one at a time, by
      # opening a http connection to the given url and calling
      # fetch_translation() on each string. Error handling and recovery
      # is performed by this method.
      # (subclass must implement fetch_translation if this method is used)
      def perform_fetch_translations(url, strings, from, to)
        translated = []
        untranslated = strings.dup
        request = Translatomatic::HTTPRequest.new(url)
        fail_count = 0 # number of consecutive translation failures

        until untranslated.empty? # request start block

          request.start do |_http|
            until untranslated.empty?
              # get next string to translate
              string = untranslated[0]
              begin
                # fetch translation
                result = fetch_translation(request, string, from, to)

                # successful translation
                fail_count = 0 # reset fail count
                translated << result
                update_translated(result)
                untranslated.shift
              rescue StandardError => e
                # translation error
                log.error(e)
                fail_count += 1
                if fail_count >= TRANSLATION_RETRIES
                  raise e # re-raise exception
                else
                  # need to restart http connection
                  # break back out to request.start block
                  break
                end
              end
            end
          end
        end

        translated
      end

      def fetch_translation(_request, _strings, _from, _to)
        raise 'subclass must implement fetch_translation'
      end

      def update_translated(texts)
        texts = [texts] unless texts.is_a?(Array)
        @updated_listener = true
        @listener.translated_texts(texts) if @listener
      end

      def perform_translate(_strings, _from, _to)
        raise 'subclass must implement perform_translate'
      end

      # Attempt to run a block of code up to retries times.
      # Reraises the exception if the block fails retries times.
      # @param retries [Number] The maximum number of times to run
      # @return [Object] the return value of the block
      def attempt_with_retries(retries)
        fail_count = 0
        begin
          yield
        rescue Exception => e
          log.error(e.message)
          fail_count += 1
          retry if fail_count < retries
          raise e
        end
      end
    end
  end
end
