# require 'telegram'
# gem 'telegram-webhooks'
Telegram.token = ENV['TELEGRAM_TOKEN']
class App < Bot
  on '/start' do |update|
    STDERR.puts '/start'
    update.message.chat.reply('Привет! Напиши что хочешь продать')
  end
  on 'start' do |update|
    STDERR.puts 'start'
    update.message.chat.reply('Привет! Напиши что хочешь продать')
  end
  on :ping do |update|
    STDERR.puts 'ping'
    update.message.chat.reply('pong')
  end
  on :echo do |update|
    STDERR.puts 'echo'
    update.message.chat.reply(update.message.text)
  end
end
