require 'bundler'
Bundler.require(:default)
require 'sinatra/base'
require 'telegram'

Telegram.token = ENV['TELEGRAM_TOKEN']

class Root < Sinatra::Base
  get '/' do
    'It works!'
  end
end

class App < Bot
  on :start do |update|
    update.message.chat.reply('Привет! Напиши что хочешь продать')
  end
  on :ping do |update|
    update.message.chat.reply('pong')
  end
  on :echo do |update|
    update.message.chat.reply(update.message.text)
  end
end

use Root
run App.new
