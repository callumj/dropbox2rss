require 'bundler'
Bundler.require :default, :web

$:.unshift File.join(File.dirname(__FILE__), "lib")

require 'dropbox2rss'