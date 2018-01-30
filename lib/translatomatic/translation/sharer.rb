module Translatomatic
  module Translation
    # Share translations with providers
    class Sharer
      def initialize(options = {})
        @options = options
      end

      # @param collection [Translatomatic::Translation::Collection]
      #   Translation collection
      # @return [void]
      def share(collection)
        return if collection.empty?

        tmx = Translatomatic::TMX::Document.from_collection(collection)
        available = Translatomatic::Provider.available(@options)
        available.each do |provider|
          if provider.respond_to?(:upload)
            log.info(t('sharer.uploading_tmx', name: provider.name))
            provider.upload(tmx)
          end
        end

        ActiveRecord::Base.transaction do
          db_texts.each do |text|
            text.update(shared: true) if text.translated?
          end
        end
      end
    end
  end
end
