require 'poparser'

module Translatomatic
  module ResourceFile
    # Property list resource file
    # @see https://en.wikipedia.org/wiki/Property_list
    class PO < Base
      # (see Base.extensions)
      def self.extensions
        %w[po pot]
      end

      # (see Base.key_value?)
      def self.key_value?
        true
      end

      # (see Base#set)
      def set(key, value)
        super(key, value)

        if @pomap.include?(key)
          po_property = @pomap[key]
          entry = po_property.entry
          if entry.plural?
            msgstr = entry.msgstr || []
            msgstr[po_property.index] = value
            entry.msgstr = msgstr
          else
            entry.msgstr = value
          end
        else
          # new key, create po entry
          @po << {
            msgid: key,
            msgstr: value
          }
          entry = @po.entries[-1]
          add_entry(entry, :msgid, 0)
        end
      end

      # (see Base#save)
      def save(target = path, options = {})
        if @po
          add_created_by unless options[:no_created_by]
          target.write(@po.to_s)
        end
      end

      private

      # used to index into PO msgstr[]
      class PoProperty
        attr_reader :entry
        attr_reader :value_index

        def initialize(entry, value_index)
          @entry = entry
          @value_index = value_index
        end

        def value
          if entry.plural?
            entry.msgstr[value_index]
          else
            entry.msgstr
          end
        end
      end

      def init
        @po = PoParser.parse('')
        @pomap = {}
      end

      def load
        content = read_contents(@path)
        @po = PoParser.parse(content)
        init_pomap(@po)
        @properties = pomap_to_properties
      end

      def add_created_by
        # TODO
      end

      # create mapping from key to PoProperty
      def init_pomap(po)
        po.entries.each_with_index do |entry, i|
          # skip PO file header if present
          # TODO: update PO-Revision-Date, Last-Translator ?
          next if entry.msgid == "" && i == 0

          add_entry(entry, :msgid, 0)
          add_entry(entry, :msgid_plural, 1) if entry.plural?
        end
      end

      def pomap_to_properties
        @pomap.transform_values { |i| i.value.to_s }
      end

      def add_entry(entry, key, index)
        map_key = entry.send(key).to_s
        return unless map_key

        context = entry.msgctxt
        map_key = map_key + "." + context.to_s if context
        @pomap[map_key] = PoProperty.new(entry, index)
      end
    end
  end
end
