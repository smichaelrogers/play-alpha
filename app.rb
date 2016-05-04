require_relative './lib/alpha'
require 'json'
require 'ostruct'

get '/' do
  erb :index
end

get '/positions' do
  @search = Alpha.init
  @data = @search.next_position
  @e = @data.to_json
  erb :show
end

post '/positions' do
  @search = params[:fen] ? Alpha.init(params[:fen]) : Alpha.init
  @data = @search.next_position
  @e = @data.to_json
  erb :show
end