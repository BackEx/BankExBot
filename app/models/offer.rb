class Offer
  include Virtus.model

  # logo_img  - урл до картинки в телеграме (при загрузки картинки мы получаем ссылку на картинку в телеграме)
  attribute :logo_img, String

  # title - заголовок
  attribute :title, String

  # description - краткое описание
  attribute :description, String

  # location - гео-локация ( массив из 2х координат [12.4322,43.4324] )
  attribute :location, Array[Decimal]

  # offer_type - тип сделки:
  #   online-video - онлайн-видео,
  #   online-audio онлайн-аудио
  #   online-chat онлайн-чат,
  #   offline - оффлайн

  attribute :offer_type, String, default: 'offline'

  # tags - теги. массив строк с решеткой   [“hi”,”yes”,”no”]
  attribute :tags, Array[String]

  # payment_type - тип оплаты:
  #   per_hour - почасовая
  #   full_price - фиксированная
  #   price - стоимость сделки
  attribute :payment_type, String, default: 'price'
end
