class AppBot
  def initialize(update)
    @message = update.inline_query ? update.inline_query : update.message
  end

  def perform
    if respond_to? command_method
      send command_method, message
    else
      reply "Нет такой комманды (/#{command}). Попробуй /start"
    end
  end

  def command_start(message)
    reply message.text
  end

  def command_ping(message)
    reply 'pong'
  end

  private

  attr_reader :message

  def reply(text)
    log "reply: #{text}"
    client.send_message(chat_id: message.chat.id, text: text)
  end

  def log(msg)
    STDERR.puts "LOG [chat_id:#{message.chat.id}]: #{msg}"
  end

  def command
    @_command ||= message.text.split(' ')[0].tr('/', '')
  end

  def command_method
    "command_#{command}"
  end

  def client
    Telegrammer::Bot.new ENV['TELEGRAM_TOKEN']
  end
end
