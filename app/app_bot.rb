require 'monetize'
require_relative 'bot_base'
require_relative 'publicator'

class AppBot < BotBase
  BOT_NAME = '@bybybankbot'

  PUBLICATE_TEXT = 'Теперь твое предложение добавлено в базу, и миллионы людей по всему миру его увидят.  Когда кто-нибудь из них решит купить твой оффер - в твой Telegram придет запрос от покупателя! Успешной торговли )'
  WELCOME_TEXT= "Здравствуйте! Я торговый бот #{BOT_NAME} #{AppVersion}! Ты можешь продать через меня все что хочешь. Просто напиши несколько смарттегов, что у тебя есть, или что ты умеешь делать - и найди своего покупателя.  Сделки регистрируются только в блокчейн записях, и процессятся напрямую через QIWI кошелек. Давай начнем!"

  def command_start
    rm = Telegrammer::DataTypes::ReplyKeyboardMarkup.new(
      keyboard: [['Создать новый оффер']],
      one_time_keyboard: true
    )

    text = WELCOME_TEXT
    client.send_message chat_id: message.chat.id, text: text, reply_markup: rm
    session_storage.set_state SessionStorage::STATE_NEW_OFFER_START
  end

  def command_offer
    session_storage.set_state SessionStorage::STATE_NEW_OFFER_START
    stage_reply
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

  def state_new_offer_start
    next_stage
  end

  def state_new_offer_title
    session_storage.set_offer_attribute :title, message.text

    next_stage
  end

  def state_new_offer_photo
    photo = message.photo[0]
    file_path = photo['file_path'] if photo
    if file_path
      session_storage.set_offer_attribute :photo_url, generate_file_url(file_path)
      next_stage
    else
      in_reply "Загрузите именно изображение"
    end
  end

  def state_new_offer_desc
    session_storage.set_offer_attribute :description, message.text

    next_stage
  end

  def state_new_offer_price
    session_storage.set_offer_attribute :price, parse.text

    next_stage
  end

  def state_new_offer_tags
    session_storage.set_offer_attribute :tags, message.text
    next_stage
  end

  def state_new_offer_location
    session_storage.set_offer_attribute :location, message.text
    next_stage
  end

  def state_new_offer_offer_type
    session_storage.set_offer_attribute :offer_type, message.text
    next_stage
  end

  def state_new_offer_publicate
    publicate?
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
      "Описание: #{offer['descrition']}",
      "Местоположение: #{offer['location']}",
      "Вид сделки: #{offer['offer_type']}",
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

  #   online-video - онлайн-видео,
  #   online-audio онлайн-аудио
  #   online-chat онлайн-чат,
  #   offline - оффлайн

  def in_reply_offer_type
    rm = Telegrammer::DataTypes::ReplyKeyboardMarkup.new(
      keyboard: [['online-video', 'online-audio'], ['online-chat', 'offline']],
      one_time_keyboard: true
    )

    text = SessionStorage::TEXTS[SessionStorage::STATE_NEW_OFFER_OFFER_TYPE]
    client.send_message chat_id: message.chat.id, text: text, reply_markup: rm
  end

  def next_stage
    session_storage.set_next_state
    stage_reply
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
