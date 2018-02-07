module Translatomatic
  module Translation
    # Translation result mungification code
    module Munging
      private

      # @private
      NoTranslateTag = Struct.new(:leading_space, :trailing_space)

      def munge_translation_results(translations)
        if use_notranslate?
          translations.collect { |tr| remove_notranslate(tr) }
        else
          translations.select { |tr| restore_preserved_text(tr) }
        end
      end

      def use_notranslate?
        @provider.class.supports_no_translate_html?
      end

      # Restore parts of text that should be preserved in the translation.
      # Used for providers that don't support translate="no" html5 attribute.
      # This works when the translator preserves parts of the string that
      # match the preserve_regex, e.g. for variables like '%{name}' if the
      # translation matches /%{.*}/ then the original text can be restored.
      # @return [Boolean] True if no errors were encountered
      def restore_preserved_text(tr)
        preserve_regex = tr.original.preserve_regex
        return true unless preserve_regex

        # find parts to preserve in the original string
        list1 = tr.original.substrings(preserve_regex)
        # find corresponding parts in the translated string
        list2 = tr.result.substrings(preserve_regex)

        return false unless list1.length == list2.length

        # we can restore text. sort by largest offset first.
        conversions = list1.zip(list2).collect.sort_by { |i| -i[0].offset }
        conversions.each do |v1, v2|
          tr.result[v2.offset, v2.length] = v1.value
        end
        true
      end

      # @param texts [Array<Text>] Texts to modify
      # @return [Array<Text>] Texts with sections to preserve wrapped in a
      #   notranslate directive.
      def wrap_notranslate(texts)
        return texts unless use_notranslate? && texts.any?(&:preserve_regex)
        texts.collect do |text|
          if text.preserve_regex
            text.gsub(text.preserve_regex) do |i|
              '<span translate="no">' + i[0] + '</span>'
            end
          else
            text
          end
        end
      end

      # Update the translation to remove notranslate directives.
      # Fixes spacing to match the original.
      # @param tr [Result] Translation result
      # @return [Result] Updated translation result
      def remove_notranslate(tr)
        return tr unless tr.original.preserve_regex
        original_spacing = find_notranslate_spacing(tr.original)
        result_spacing = find_notranslate_spacing(tr.result)
        if original_spacing.length != result_spacing.length
          # the number of notranslate directives in the result doesn't
          # match the number in the original. this could mean an invalid
          # translation?
          log.debug("possible invalid translation: #{tr.description}")
          original_spacing = nil # don't attempt to fix spacing.
        end
        original = remove_notranslate_text(tr.original)
        result = remove_notranslate_text(tr.result, original_spacing)
        Result.new(
          original, result, tr.provider, from_database: tr.from_database
        )
      end

      REGEX1 = %r{<span translate="no">\s*(.*?)\s*</span>}
      REGEX2 = %r{(\s*)<span translate="no">\s*(.*?)\s*</span>(\s*)}

      # scan text for no translate tags, record leading and trailing space.
      def find_notranslate_spacing(text)
        text.scan(REGEX2).collect { |i| [i[0], i[2]] }
      end

      def remove_notranslate_text(text, fix_spacing = nil)
        if fix_spacing
          num = 0 # match number
          text.gsub(REGEX2) do |i|
            notranslate_replacement(i[2], fix_spacing, num += 1)
          end
        else
          text.gsub(REGEX1) { |i| i[1] }
        end
      end

      def notranslate_replacement(string, fix_spacing, num)
        spacing = fix_spacing[num - 1]
        leading = spacing[0]
        trailing = spacing[1]
        leading + string + trailing
      end
    end
  end
end
