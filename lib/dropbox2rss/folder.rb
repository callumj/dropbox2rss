# encode: UTF-8

module Dropbox2Rss

  class Folder

    attr_accessor :path
    attr_reader   :client

    def initialize(path, client = Dropbox2Rss.dropbox_client)
      self.path = path
      @client = client
    end

    def title
      path.gsub(/\.\w{3,3}/, "")
    end

    def files
      @files ||= client.ls path
    end

    def playable_files
      files.select { |file| file.path.match /\.m4a$/ }
    end

    def playable_items
      @playable_items ||= playable_files.map do |file|
        File.new(file, client)
      end.sort_by(&:date).reverse.first(Dropbox2Rss.num_items_to_show)
    end

    def date
      @date ||= (playable_items.first.try { |item|  item.date } || Time.now.utc)
    end

    def as_builder(scope, &block)
      link = block_given? ? yield(self) : ""

      scope.title           { scope.cdata(title) }
      scope.link            URI.encode(link)
      scope.pubDate         date.rfc822
      scope.lastBuildDate   date.rfc822
      scope.description     { scope.cdata(title) }
      playable_items.each { |item| item.as_builder(scope, &block) }
    end

  end

end