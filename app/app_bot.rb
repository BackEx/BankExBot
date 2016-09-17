require_relative 'bot_base'

class AppBot < BotBase
  def command_start
    reply 'Введите /offer для публикации предложения'
  end

  def command_offer
    reply 'Введите заголовок объявления'
    session_storage.set_state SessionStorage::STATE_NEW_OFFER_TITLE
  end

  def command_ping
    reply 'pong'
  end

  def command_debug
    reply session_storage.get_offer.to_s
  end

  def state_new_offer_title
    reply "Заголовок: #{message.text}"
    session_storage.set_next_state
    session_storage.set_offer_attribute :title, message.text
  end

  def state_new_offer_description
    reply "Описание: #{message.text}"
    session_storage.set_next_state
  end
end
