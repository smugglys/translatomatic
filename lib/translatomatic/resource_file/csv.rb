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
      def save(target = path, _options = {})
        use_headers = @options[:csv_headers]
        csv_options = { write_headers: use_headers }
        csv_options.merge!(headers: @headers) if use_headers

        ::CSV.open(target, 'wb', csv_options) do |csv|
          @rows.each do |row|
            csv << row.collect { |i| i.value }
          end
        end
      end

      private

      DEFAULT_KEY_COLUMN = 'key'
      DEFAULT_VALUE_COLUMN = 'value'

      define_option :csv_headers, type: :boolean, default: false,
                    desc: t('file.csv.headers')
      define_option :csv_columns, type: :array,
                    desc: t('file.csv.columns')
      define_option :csv_key_column, default: DEFAULT_KEY_COLUMN,
                    desc: t('file.csv.key_column')
      define_option :csv_value_column, default: DEFAULT_VALUE_COLUMN,
                    desc: t('file.csv.value_column')

      Cell = Struct.new(:header, :key, :value, :translate)

      def init
        @rows = []
        @cellmap = {} # map of String key -> Cell
        @rownum = 0
        @key_column = @options[:csv_key_column] || 'key'
        @value_column = @options[:csv_value_column] || 'value'
        @columns = @options[:csv_columns]
      end

      def add_row(key, value)
        load_row(@key_column => key, @value_column => value)
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

      # row is a hash of column -> value
      # @return [Array<Cell>] cells
      def load_hash_row(row)
        cells = []
        # add a property for each column
        colnum = 0
        row.each do |column, value|
          colnum += 1
          translate = @columns.blank? || @columns.include?(column)
          key = "key#{@rownum},#{colnum}"
          cells << Cell.new(column, key, value, translate)
        end
        cells
      end

      # row is an array of values
      # @return [Array<Cell>] cells
      def load_array_row(row)
        cells = []
        row.each_with_index do |value, i|
          translate = @columns.blank? || @columns.include?((i + 1).to_s)
          key = "key#{@rownum},#{i + 1}"
          cells << Cell.new("column#{i + 1}", key, value, translate)
        end
        cells
      end
    end
  end
end
