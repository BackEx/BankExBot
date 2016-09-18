require 'monetize'
require_relative 'bot_base'
require_relative 'publicator'

class AppBot < BotBase
  PUBLICATE_TEXT = 'Теперь твое предложение добавлено в базу, и миллионы людей по всему миру его увидят.  Когда кто-нибудь из них решит купить твой оффер - в твой Telegram придет запрос от покупателя! Успешной торговли )'

  def command_start
    reply "Введите /offer для публикации предложения. #{AppVersion}"
  end

  def command_publicate
    command_Опубликовать
  end

  def command_Опубликовать
    reply 'Публикую..'
    res = Publicator.new(from: message.from, offer: offer).publicate!
    reply "Опубликовал: #{res}"
    session_storage.clear_state
  end

  def command_offer
    session_storage.set_state SessionStorage::STATE_NEW_OFFER_TITLE
    stage_reply
  end

  def state_new_offer_title
    session_storage.set_offer_attribute :title, message.text

    session_storage.set_next_state
    stage_reply
  end

  def state_new_offer_photo
    photo = generate_file_url message.photo[0]
    if photo
      session_storage.set_offer_attribute :photo_url, generate_file_url(message.photo[0].file_path)

      session_storage.set_next_state
      stage_reply
    else
      in_reply "Загрузите именно изображение"
    end
  end

  def state_new_offer_desc
    session_storage.set_offer_attribute :description, message.text

    session_storage.set_next_state
    stage_reply
  end

  def state_new_offer_price
    money = Monetize.parse message.text
    session_storage.set_offer_attribute :price, money.to_f

    session_storage.set_next_state
    stage_reply
  end

  def state_new_offer_tags
    session_storage.set_offer_attribute :tags, message.text
    session_storage.set_next_state
    stage_reply
  end

  def state_new_offer_location
    session_storage.set_offer_attribute :location, message.text
    session_storage.set_next_state
    stage_reply
  end

  def state_new_offer_offer_type
    session_storage.set_offer_attribute :offer_type, message.text
    session_storage.set_next_state
    stage_reply
  end

  def state_new_offer_publicate
    publicate?
  end

  #   online-video - онлайн-видео,
  #   online-audio онлайн-аудио
  #   online-chat онлайн-чат,
  #   offline - оффлайн

  def in_reply_offer_type
    session_storage.set_offer_attribute :offer_type, message.text
    rm = Telegrammer::DataTypes::ReplyKeyboardMarkup.new(
      keyboard: [['online-video', 'online-audio'], ['online-chat', 'offline']],
      one_time_keyboard: true
    )

    text = SessionStorage::TEXTS[STATE_NEW_OFFER_OFFER_TYPE]
    client.send_message chat_id: message.chat.id, text: text, reply_markup: rm
  end

  def publicate?
    rm = Telegrammer::DataTypes::ReplyKeyboardMarkup.new(
      keyboard: [['/Опубликовать']],
      one_time_keyboard: true
    )

    text = "У нас получилось следующее объявление.\n---\n#{offer_text}\n---\nПубликуем?"
    client.send_message chat_id: message.chat.id, text: text, reply_markup: rm
  end

  def offer_text
    [
      "Заголовок: #{offer['title']}",
      "Описание: #{offer['descriiption']}",
      "Цена: #{offer['price']}",
      "Теги: #{offer['tags']}"
    ].join("\n")
  end

  def offer
    session_storage.get_offer
  end

  def stage_reply
    state = session_storage.get_state
    return 'нечего сказать' unless state

    if state == SessionStorage::STATE_NEW_OFFER_PUBLICATE
      publicate?
    elsif state == SessionStorage::STATE_NEW_OFFER_OFFER_TYPE
      in_reply_offer_type
    else
      in_reply SessionStorage::TEXTS[state]
    end
  end

  def command_debug
    data = {
      offer: offer,
      state: session_storage.get_state,
      next_state: session_storage.next_state,
      from: message.from.to_h,
      version: AppVersion.to_s
    }
    reply data.to_s
  end

end
