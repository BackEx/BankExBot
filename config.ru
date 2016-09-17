require 'bundler'
Bundler.require(:default)
require 'sinatra/base'

class Root < Sinatra::Base
  get '/' do
    STDERR.puts 'works'
    'It works!'
  end
  post '/' do
    request.body.rewind
    payload = JSON.parse(request.body.read) rescue {}
    STDERR.puts "payload: #{payload}"

    update = Telegrammer::DataTypes::Update.new(
      update_id: payload[:update_id],
      message: payload[:message]
    )
    STDERR.puts "update: #{update}"
    STDERR.puts "params: #{params}"
    'Ok'
  end
end

bot = Telegrammer::Bot.new ENV['TELEGRAM_TOKEN']

# use Root
run Root
