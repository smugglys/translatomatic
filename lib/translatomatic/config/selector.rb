module Translatomatic
  module Config
    # Selects which set of config settings to use
    class Selector
      attr_reader :for_file
      attr_reader :location

      def initialize(settings, default_location, params = {})
        @settings = settings
        @for_file = params[:for_file]
        @location = params[:location]
        @default_location = default_location
      end

      # Find a settings object for reading the specified option
      # @param key [Symbol] Option name
      # @return [LocationSettings] settings
      def settings_for_read(key)
        if location.nil?
          # no location, find first settings for key according to precedence
          settings_with_precedence(key)
        else
          # location is set
          check_valid_location
          location_settings_for_read(key, location)
        end
      end

      # Find a settings object for writing the specified option
      # @param key [Symbol] Option name
      # @return [LocationSettings] settings
      def settings_for_write(key)
        effective = effective_location(key, location)
        settings = @settings[effective]
        if for_file
          path = file(settings)
          data = settings.files[path.to_s.to_sym] ||= {}
          file_location_settings(settings, data)
        else
          settings
        end
      end

      private

      include Translatomatic::TypeCast

      # valid location list in order of precedence
      LOCATIONS = %i[runtime project user env].freeze

      def settings_with_precedence(key)
        # find the first setting found by precedence
        LOCATIONS.each do |loc|
          settings = location_settings_for_read(key, loc)
          return settings if settings
        end
        nil
      end

      def location_settings_for_read(key, loc)
        effective = effective_location(key, loc)
        settings = @settings[effective]
        file_settings = for_file_settings(settings)
        [file_settings, settings].each do |i|
          return i if i && i.include?(key)
        end
        return nil
      end

      def effective_location(key, loc)
        effective = loc || @default_location
        effective = :user if Options.option(key).user_location_only
        effective
      end

      def check_valid_location
        valid = valid_location?
        raise t('config.invalid_location', location: location) unless valid
      end

      def valid_location?
        location.present? && LOCATIONS.include?(location.to_sym)
      end

      def for_file_settings(settings)
        return nil unless for_file
        data = merged_file_data(settings)
        file_location_settings(settings, data)
      end

      def file(settings)
        path = Pathname.new(for_file)
        unless path.relative?
          settings_path = Pathname.new(settings.path)
          path = path.relative_path_from(settings_path)
        end
        path
      end

      # find matching file configurations
      def merged_file_data(settings)
        merged_data = {}
        file = file(settings)
        paths = settings.files.keys.collect(&:to_s)
        paths.sort_by(&:length).each do |path|
          next unless path_match?(file, path)
          merged_data.merge!(settings.files[path.to_sym])
        end
        merged_data
      end

      # check if file is equal to or a child of the given path
      def path_match?(file, path)
        file.to_s == path || file.to_s.start_with?(path.to_s)
      end

      def file_location_settings(settings, data)
        options = {
          path: settings.path,
          location: settings.location,
          no_files: true
        }
        LocationSettings.new(data, options)
      end
    end
  end
end
