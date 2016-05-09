require 'rubygems'
require 'bundler'
Bundler.require(:default)
require './lib/alpha'
require './app'


map '/assets' do
  e = Sprockets::Environment.new
  %w(javascripts stylesheets fonts).each { |path| e.append_path("assets/#{path}") }
  configure :production do
    e.js_compressor = :uglify
    e.css_compressor = :scss
    AutoprefixerRails.install(e)
  end
  
  run e
end

map '/' do
  run Sinatra::Application
end
