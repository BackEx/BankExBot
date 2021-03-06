class SessionStorage
  include Virtus.model

  attribute :chat_id
  attribute :from_id

  NS = 'sessions:'

  STATE_NEW_OFFER_START       = 'new_offer_start'
  STATE_NEW_OFFER_TITLE       = 'new_offer_title'
  STATE_NEW_OFFER_PHOTO       = 'new_offer_photo'
  STATE_NEW_OFFER_DESCRIPTION = 'new_offer_desc'
  STATE_NEW_OFFER_PRICE       = 'new_offer_price'
  STATE_NEW_OFFER_TAGS        = 'new_offer_tags'
  STATE_NEW_OFFER_LOCATION    = 'new_offer_location'
  STATE_NEW_OFFER_OFFER_TYPE  = 'new_offer_offer_type'
  STATE_NEW_OFFER_PUBLICATE   = 'new_offer_publicate'

  STATES = [
    STATE_NEW_OFFER_START,
    STATE_NEW_OFFER_TITLE,
    STATE_NEW_OFFER_PHOTO,
    STATE_NEW_OFFER_DESCRIPTION,
    STATE_NEW_OFFER_PRICE,
    STATE_NEW_OFFER_TAGS,
    STATE_NEW_OFFER_LOCATION,
    STATE_NEW_OFFER_OFFER_TYPE,
    STATE_NEW_OFFER_PUBLICATE
  ]

  TEXTS = {
    STATE_NEW_OFFER_TITLE       => 'Напиши Заголовок для своего оффера. Пару слов что ты хочешь продать?',
    STATE_NEW_OFFER_DESCRIPTION => 'Ты продашь свой оффер быстрее, если сделаешь краткое описание, пару предложений что ты хочешь продать?',
    STATE_NEW_OFFER_TAGS        => 'Хештегами люди ищут информацию. Смарттегами люди ищут сделки, введи несколько смарттегов для своих покупателей через запятую: образец - $smartteg1, $smartteg2, $smartteg3',
    STATE_NEW_OFFER_LOCATION    => 'Люди из твоего города купят твой оффер охотнее. Напиши свой город',
    STATE_NEW_OFFER_OFFER_TYPE  => 'Выбери как ты хочешь продать свой оффер:',
    STATE_NEW_OFFER_PRICE       => 'Теперь самое главное: напиши цену за свой оффер, что бы ее мог купить иностранец, напиши число в долларах',
    STATE_NEW_OFFER_PHOTO       => 'Мы будем показывать твой оффер покупателям в виде классной картинки. Отправь картинку, подходящую под твой оффер'
  }

  def next_state
    index = STATES.index get_state
    return nil if index.nil?
    STATES[index + 1]
  end

  def set_next_state
    set_state next_state
  end

  def get_state
    redis.get key(:state)
  end

  def set_state(state)
    redis.set key(:state), state
  end

  def clear_state
    redis.del key(:state)
  end

  def set_offer_attribute(attribute, value)
    redis.hset key(:offer), attribute, value
  end

  def get_offer
    redis.hgetall key(:offer)
  end

  private

  def key(value)
    [NS, chat_id, from_id, value].join(':')
  end

  def redis
    $redis ||= Redis.new #(:host => "10.0.1.1", :port => 6380, :db => 15)
  end
end
