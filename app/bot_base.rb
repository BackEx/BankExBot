class BotBase
  def initialize(update)
    @message = update.inline_query ? update.inline_query : update.message
  end

  def perform
    if command && respond_to?(command_method)
      send command_method
    else
      if session_storage.get_state
        STDERR.puts 'get_state'
        if respond_to? state_method
          STDERR.puts 'responde'
          send state_method
        else
          reply "Нет обработчика для этого состояния (#{session_storage.get_state})"
        end
      else
        reply "Нет такой комманды (/#{command}). Попробуй /start"
      end
    end
  end

  def command_state
    reply session_storage.get_state || 'no state'
  end

  private

  attr_reader :message

  def state_method
    state = session_storage.get_state
    "state_#{state}"
  end

  def reply(text)
    log "reply: #{text}"
    client.send_message(chat_id: message.chat.id, text: text)
  end

  def log(msg)
    STDERR.puts "LOG [chat_id:#{message.chat.id}]: #{msg}"
  end

  def command
    first = message.text.split(' ')[0]
    if first[0]=='/'
      first.tr('/','')
    else
      nil
    end
  end

  def command_method
    "command_#{command}"
  end

  def session_storage
    @session_storage ||= SessionStorage.new(message.chat.id)
  end

  def client
    Telegrammer::Bot.new ENV['TELEGRAM_TOKEN']
  end
end