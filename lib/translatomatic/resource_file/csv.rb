require 'csv'

module Translatomatic
  module ResourceFile
    # CSV resource file
    class CSV < Base
      # (see Base.extensions)
      def self.extensions
        %w[csv]
      end

      # (see Base#set)
      def set(key, value)
        super(key, value)
        if @cellmap.include?(key)
          @cellmap[key].value = value
        else
          add_row(key, value)
        end
      end

      # (see Base#save)
      def save(target = path, options = {})
        use_headers = @options[:csv_headers]
        csv_options = { write_headers: use_headers }
        csv_options[:headers] = @headers if use_headers

        ::CSV.open(target, 'wb', csv_options) do |csv|
          @rows.each do |row|
            csv << row.collect(&:value)
          end
        end
      end

      private

      DEFAULT_KEY_COLUMN = 'key'.freeze
      DEFAULT_VALUE_COLUMN = 'value'.freeze
      DEFAULT_COMMENT_COLUMN = 'comments'.freeze
      CONTEXT_COLUMN = 'tm.context'.freeze

      define_option :csv_headers, type: :boolean, default: false,
                                  desc: t('file.csv.headers')
      define_option :csv_translate_columns, type: :array,
                                            desc: t('file.csv.translate_columns')
      define_option :csv_key_column, default: DEFAULT_KEY_COLUMN,
                                     desc: t('file.csv.key_column')
      define_option :csv_value_column, default: DEFAULT_VALUE_COLUMN,
                                       desc: t('file.csv.value_column')
      define_option :csv_comment_column, default: DEFAULT_COMMENT_COLUMN,
                                         desc: t('file.csv.comment_column')

      # @private
      Cell = Struct.new(:header, :key, :value, :translate)

      def init
        @rows = []
        @cellmap = {} # map of String key -> Cell
        @rownum = 0
        @key_column = option(:csv_key_column, DEFAULT_KEY_COLUMN)
        @value_column = option(:csv_value_column, DEFAULT_VALUE_COLUMN)
        @comments_column = option(:csv_comment_column, DEFAULT_COMMENT_COLUMN)
        @translate = option(:csv_translate_columns)
      end

      def option(key, default = nil)
        @options[key] || default
      end

      def add_row(key, value)
        @rows << load_row(@key_column => key, @value_column => value)
      end

      def load
        contents = read_contents(@path)
        csv_options = { headers: @options[:csv_headers] }

        @rows = []
        @rownum = 0

        csv = ::CSV.parse(contents, csv_options)
        csv.each do |row|
          @rows << load_row(row)
        end

        init_properties
      end

      # initialise properties and cellmap from @rows
      def init_properties
        @properties = {}
        @cellmap = {}
        @rows.each do |row|
          row.each do |cell|
            @properties[cell.key] = cell.value if cell.translate
            @cellmap[cell.key] = cell
          end
        end
      end

      # @param row [Array<Cell>] row to convert to hash
      def row_to_hash(row)
        hash = {}
        row.each do |cell|
          hash[cell.header] = cell.value
        end
        hash
      end

      def load_row(row)
        @rownum += 1
        if row.is_a?(::CSV::Row)
          @headers = row.headers
          load_hash_row(row.to_h)
        elsif row.is_a?(Hash)
          load_hash_row(row)
        elsif row.is_a?(Array)
          load_array_row(row)
        else
          raise "invalid row data: #{row}"
        end
      end

      # row is an array of values
      # @return [Array<Cell>] cells
      def load_array_row(row)
        cells = []
        row.each_with_index do |value, i|
          translate = translate_column?((i + 1).to_s)
          key = "key#{@rownum},#{i + 1}"
          cells << Cell.new("column#{i + 1}", key, value, translate)
        end
        parse_metadata(cells)
        cells
      end

      # row is a hash of column -> value
      # @return [Array<Cell>] cells
      def load_hash_row(row)
        cells = []
        # add a property for each column
        colnum = 0
        row.each do |column, value|
          colnum += 1
          translate = translate_column?(column)
          key = "key#{@rownum},#{colnum}"
          cells << Cell.new(column, key, value, translate)
        end
        parse_metadata(cells)
        cells
      end

      def translate_column?(column)
        if @translate.present?
          # translation columns specified
          @translate.include?(column)
        elsif have_target_locale_column?
          # if there is a column matching the target locale, translate that
          # column only.
          column == @target_locale.to_s
        else
          # translate if it's not the key column or comments column
          column != @key_column && column != @comments_column
        end
      end

      def have_target_locale_column?
        @have_target_locale_column ||= begin
          @target_locale && @headers &&
            @headers.include?(@target_locale.to_s)
        end
      end

      def parse_metadata(row)
        comments_cell = find_cell(row, @comments_column)
        return unless comments_cell
        @metadata.parse_comment(comments_cell.value)
        row.each do |cell|
          @metadata.assign_key(cell.key, keep_context: true) if cell.translate
        end
        @metadata.clear_context
      end

      def find_cell(row, column_name)
        row.find { |i| i.header == column_name }
      end
    end
  end
end
