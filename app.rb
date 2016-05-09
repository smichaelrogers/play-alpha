get '/' do
  erb :index
end

post '/positions' do
  alpha = Alpha::Search.new(params[:fen])
  alpha.find_move(2.0)
  json alpha.data.to_json
end
