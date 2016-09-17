class Core
  def post(offer)
    raise "(#{offer}) must be a Offer" unless offer.is_a? Offer
    conn.post do |req|
      req.url '/offer.post'
      req.headers['Content-Type'] = 'application/json'
      req.body = JSON.generate(offer.to_h)
    end
  end

  private

  def connection
    @_connection = Faraday.new(:url => ENV['CORE_URL']) do |faraday|
      # faraday.request  :url_encoded             # form-encode POST params
      # faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end
end
