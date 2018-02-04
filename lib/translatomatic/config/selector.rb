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
          location_settings(key, location)
        end
      end

      # Find a settings object for writing the specified option
      # @param key [Symbol] Option name
      # @return [LocationSettings] settings
      def settings_for_write(key)
        location_settings(key, location || @default_location, true)
      end

      private

      include Translatomatic::TypeCast

      # valid location list in order of precedence
      LOCATIONS = %i[project user env].freeze

      def settings_with_precedence(key)
        # find the first setting found by precedence
        LOCATIONS.each do |loc|
          settings = location_settings(key, loc)
          return settings if settings && settings.include?(key)
        end
        nil
      end

      def location_settings(key, loc, write = false)
        effective = effective_location(key, loc)
        settings = @settings[effective]
        for_file ? for_file_settings(settings, write) : settings
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

      def for_file_settings(settings, write = false)
        file = Pathname.new(for_file)
        file = file.relative_path_from(settings.path) unless file.relative?
        data = for_file_data(settings, file, write)
        file_location_settings(settings, data)
      end

      def for_file_data(settings, file, write = false)
        if write
          settings.files[file.to_s] ||= {}
        else
          merged_file_data(settings, file)
        end
      end

      # find matching file configurations
      def merged_file_data(settings, file)
        merged_data = {}
        settings.files.keys.sort_by(&:length).each do |path|
          next unless path_match?(file, path)
          merged_data.merge!(settings.files[path])
        end
        merged_data
      end

      # check if file is equal to or a child of the given path
      def path_match?(file, path)
        file.to_s == path || file.to_s.start_with?(path)
      end

      def file_location_settings(settings, data)
        options = { path: settings.path, location: settings.location }
        LocationSettings.new(data, options)
      end
    end
  end
end
