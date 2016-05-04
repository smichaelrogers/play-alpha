require 'rubygems'
require 'bundler'
Bundler.require(:default)
require './app'

map '/assets' do
  e = Sprockets::Environment.new
  %w(javascripts stylesheets templates).each { |path| e.append_path("assets/#{path}") }
  configure :production, :test do
    e.js_compressor = :uglify
    e.css_compressor = :scss
  end
  run e
end

map '/' do
  run Sinatra::Application
end