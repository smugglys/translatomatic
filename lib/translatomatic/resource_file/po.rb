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
            msgstr[po_property.msgstr_index] = value
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

      PO_DATE_FORMAT = '%Y-%M-%d %HH:%MM%Z'.freeze

      # used to index into PO msgstr[]
      # @private
      class PoProperty
        attr_reader :entry
        attr_reader :msgstr_index

        def initialize(entry, msgstr_index)
          @entry = entry
          @msgstr_index = msgstr_index
        end

        def value
          if entry.plural?
            entry.msgstr[msgstr_index]
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
        @metadata.reset
        content = read_contents(@path)
        @po = PoParser.parse(content)
        init_pomap(@po)
        @properties = pomap_to_properties
      end

      def add_created_by
        header = po_header
        header['PO-RevisionDate'] = Time.now.strftime(PO_DATE_FORMAT)
        header['Last-Translator'] = 'Translatomatic ' + VERSION
      end

      def po_header
        # TODO: get or create header entry
        {}
      end

      # create mapping from key to PoProperty
      def init_pomap(po)
        po.entries.each_with_index do |entry, i|
          # skip PO file header if present
          # TODO: update PO-Revision-Date, Last-Provider ?
          next if entry.msgid == '' && i == 0

          if entry.extracted_comment
            @metadata.parse_comment(entry.extracted_comment.value)
          end
          add_entry(entry, :msgid, 0)
          add_entry(entry, :msgid_plural, 1) if entry.plural?
          @metadata.clear_context
        end
      end

      def pomap_to_properties
        @pomap.transform_values { |i| i.value.to_s }
      end

      def add_entry(entry, key, msgstr_index)
        map_key = entry.send(key).to_s
        return unless map_key

        msg_context = entry.msgctxt
        map_key = map_key + '.' + msg_context.to_s if msg_context
        @pomap[map_key] = PoProperty.new(entry, msgstr_index)
        @metadata.assign_key(map_key, keep_context: true)
      end
    end
  end
end
