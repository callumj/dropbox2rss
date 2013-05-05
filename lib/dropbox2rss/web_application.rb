# encode: UTF-8
require 'sinatra/base'

module Dropbox2Rss
  class WebApplication < Sinatra::Base

    get '/file/*' do
      file = Dropbox2Rss::File.new params[:splat].first
      redirect file.download_url
    end

    get '/folder/:name.:format', provides: ['xml', 'rss'] do
      content_type "application/rss+xml"

      folder = Dropbox2Rss::Folder.new params[:name]

      nokogiri(nil, encoding: "UFT-8") do |xml|
        xml.rss(version: "2.0") do |rss|
          rss.channel do |channel|
            folder.as_builder(channel) do |linkable|
              "#{request.base_url}/file/#{linkable.path}"
            end
          end
        end
      end
    end

  end
end