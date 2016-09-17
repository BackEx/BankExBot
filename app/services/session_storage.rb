class SessionStorage
  NS = 'sessions:'

  STATE_NEW_OFFER_TITLE       = 'new_offer_title'
  STATE_NEW_OFFER_DESCRIPTION = 'new_offer_desc'
  STATE_NEW_OFFER_PRICE       = 'new_offer_price'
  STATE_NEW_OFFER_TAGS        = 'new_offer_tags'
  STATE_NEW_OFFER_PUBLICATE   = 'new_offer_publicate'

  STATES = [
    STATE_NEW_OFFER_TITLE,
    STATE_NEW_OFFER_DESCRIPTION,
    STATE_NEW_OFFER_PRICE,
    STATE_NEW_OFFER_TAGS,
    STATE_NEW_OFFER_PUBLICATE
  ]

  def initialize(chat_id)
    @chat_id = chat_id
  end

  def next_state
    index = STATES.index get_state
    return nil if index.nil?
    STATES[index + 1]
  end

  def set_next_state
    set_state next_state
  end

  def get_state
    get 'state'
  end

  def set_state(state)
    set 'state', state
  end

  def set_offer_attribute(attribute, value)
    redis.hset NS+'offer', attribute, value
  end

  def get_offer
    redis.hgetall NS+'offer'
  end

  private

  attr_reader :chat_id

  def set(key, data)
    redis.set NS + key, data
  end

  def get(key)
    redis.get NS + key
  end

  def redis
    $redis ||= Redis.new #(:host => "10.0.1.1", :port => 6380, :db => 15)
  end
end
