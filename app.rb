require 'rubygems'
require 'bundler'
Bundler.require(:default, (ENV['RACK_ENV'] || 'development').to_sym)
require './lib/alpha'
require 'sinatra/json'
require 'json'

class App < Sinatra::Application
  
  get '/' do
    erb :index
  end

  post '/api/search' do
    @alpha = Alpha::Search.new
    
    unless params[:fen] && @alpha.load_position(params[:fen])
      @alpha.load_position
    end
    
    @alpha.find_move(duration: 2.0)
    
    if @alpha.game_over?
      redis.lpush('results', @alpha.result)
    end
    
    json @alpha.data.to_json
  end
  
  
  def redis
    $redis ||= Redis.connect(url: settings.production? ? ENV['REDISCLOUD_URL'] : 'redis://localhost:6379')
  end
  
end