require 'bundler'
Bundler.require(:default)
require 'sinatra/base'

MyBot = Telegrammer::Bot.new ENV['TELEGRAM_TOKEN']

class Root < Sinatra::Base
  get '/' do
    STDERR.puts 'works'
    'It works!'
  end
  post '/' do
    request.body.rewind
    payload = JSON.parse(request.body.read) rescue {}
    STDERR.puts "payload: #{payload}"

    update = Telegrammer::DataTypes::Update.new(payload)

    MyBot.send_message(chat_id: update.message.chat.id, text: "You said: #{update.message.text}")

    'Ok'
  end
end

# use Root
run Root
