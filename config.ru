require './app'

map '/assets' do
  e = Sprockets::Environment.new
  e.append_path('assets/javascripts')
  e.append_path('assets/stylesheets')
  AutoprefixerRails.install(e)
  run e
end

map '/' do
  run App
end
