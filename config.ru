Bundler.require(:default)
require 'telegram'

Telegram.token = ENV['TELEGRAM_TOKEN']

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

run App.new
