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
    reply "Установлен заголовок: #{message.text}. Введите описание."
    session_storage.set_next_state
    session_storage.set_offer_attribute :title, message.text
  end

  def state_new_offer_desc
    reply "Установлено описание: #{message.text}. Введите цену."
    session_storage.set_next_state
    session_storage.set_offer_attribute :description, message.text
  end

  def state_new_offer_price
    money = Money.parse message.text
    reply "Установлена цена: #{money}. Введите теги через запятую"
    session_storage.set_next_state
    session_storage.set_offer_attribute :price, money.to_f
  end

  def state_new_offer_tags
    tags = message.text.split(',')
    reply "Теги: #{tags.join(',')}"
    session_storage.set_next_state
    session_storage.set_offer_attribute :tags, tags.join(',')
  end
end
