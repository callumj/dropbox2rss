# encode: UTF-8

module Dropbox2Rss
  class File

    attr_accessor :client
    attr_reader   :file

    def initialize(path_or_obj, client = Dropbox2Rss.dropbox_client, options = {})
      self.client = client

      if path_or_obj.is_a?(Dropbox::API::File)
        @file = path_or_obj
      else
        @file = client.find path_or_obj
      end

      @description = options[:description]
    end

    def path
      file.path
    end

    def title
      path.match(/\/([^\/]*)$/).try(:[], 1).try do |str|
        str.gsub(/\.\w{3,3}/, "")
      end
    end

    def date
      @date ||= Time.parse(file.modified)
    end

    def description
      return "" unless Dropbox2Rss.include_description_companion?
      @description ||= begin
        companion = client.find("#{path}.txt") rescue nil
        if companion
          companion.download
        else
          ""
        end
      end
    end

    def download_url
      file.direct_url.try(:[], "url")
    end

    def as_builder(scope, &block)
      link = block_given? ? yield(self) : download_url
      encoded_link = URI.encode(link)

      scope.item do |item|
        item.title       { item.cdata(title) }
        item.link        encoded_link
        item.enclosure(url: encoded_link, type: file.mime_type)
        item.pubDate     date.rfc822
        item.guid        { item.cdata(encoded_link) }
        item.description { item.cdata("A thing") }
      end
    end

  end

end