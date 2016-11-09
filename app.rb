require 'rubygems'
require 'bundler'
Bundler.require(:default, (ENV['RACK_ENV'] || 'development').to_sym)
require './lib/alpha'


get '/' do
  erb :index, layout: false
end

post '/search' do
  content_type :json

  @alpha = Alpha::Search.new
  unless params[:fen] && @alpha.load_position(params[:fen])
    @alpha.load_position
  end
  @alpha.find_move(duration: 1.0)

  @alpha.data.to_json
end
