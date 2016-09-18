class Publicator
  include Virtus.model

  URL = 'http://bankex.awa.finance'

  # curl -X POST -d '{"photo_url":"http://grigory.ozhegov.name/static/img/vk.png", "telegram_id": "104", "title": "Бараночки", \
  #   "description": "Бараночки в коробках", "price": 100, "tags": "хлеб,продукты", "offer_type":"offline", "location":"Москва"}' \
  #   "http://bankex.awa.finance/api/offers.publish"
  #

  attribute :from, Telegrammer::DataTypes::User
  attribute :offer, Hash

  def publicate!
    body = {
      telegram_id: from.id,
      telegram_nick: from.username,
      photo_url:   offer['photo_url'],
      description: offer['description'],
      title:       offer['title'],
      price:       offer['price'].to_i,
      tags:        offer['tags'],
      location:    offer['location'],
      offer_type:  offer['offer_type']
    }
    body = JSON.generate(body.to_h)
    STDERR.puts body
    response = connection.post do |req|
      req.url '/api/offers.publish'
      req.headers['Content-Type'] = 'application/json'
      req.body = body
    end
    response.body
  end

  # curl -X POST -d '{"telegram_id":104, "telegram_nick": "lolka", "about": "lolka"}' "http://bankex.awa.finance/api/salesman.register"

  def register!
    body = {
      telegram_id:   from.id,
      telegram_nick: from.username,
      about: '...'
    }
    body = JSON.generate(body.to_h)
    STDERR.puts body
    connection.post do |req|
      req.url '/api/salesman.register'
      req.headers['Content-Type'] = 'application/json'
      req.body = body
    end
  end

  private

  def tags
    offer['tags'].split(',').map(&:strip)
  end

  def connection
    @_connection = Faraday.new(url: URL) do |faraday|
      # faraday.request  :url_encoded             # form-encode POST params
      # faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end
end
