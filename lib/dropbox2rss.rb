module Dropbox2Rss

  require 'dropbox-api'
  require 'active_support/core_ext/hash'
  require 'active_support/core_ext/object'
  require 'nokogiri'

  require 'dropbox2rss/folder'
  require 'dropbox2rss/file'
  require 'dropbox2rss/web_application'

  def self.configuration
    @configuration ||= begin
      base = ::File.join(::File.dirname(__FILE__), "../")
      YAML::load_file(ENV["APP_CONFIG_FILE"] || ::File.join(base, "config", "application.yaml")).with_indifferent_access
    end
  end

  def self.dropbox_client
    configure_dropbox!
    Dropbox::API::Client.new token: configuration[:dropbox][:user_token], secret: configuration[:dropbox][:user_secret]
  end

  def self.configure_dropbox!
    Dropbox::API::Config.app_key    = configuration[:dropbox][:app_key]
    Dropbox::API::Config.app_secret = configuration[:dropbox][:app_secret]
    Dropbox::API::Config.mode       = configuration[:dropbox][:mode]
  end

  def self.include_description_companion?
    configuration[:description_file] && configuration[:description_file][:enabled]
  end

  def self.num_items_to_show
    configuration[:items_to_show] || 3
  end

end