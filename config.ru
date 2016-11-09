require './app'

map '/assets' do
  sprockets = Sprockets::Environment.new
  sprockets.append_path('assets/javascripts')
  sprockets.append_path('assets/stylesheets')
  sprockets.js_compressor  = :uglify
  sprockets.css_compressor = :scss
  
  AutoprefixerRails.install(sprockets)
  run sprockets
end

map '/' do
  run Sinatra::Application
end
