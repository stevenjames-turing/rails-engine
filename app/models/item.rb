class Item < ApplicationRecord
  # Model Validations
  validates_presence_of :name,
                        :description,
                        :unit_price,
                        :merchant_id

  # Model Relationships
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items
  belongs_to :merchant

  def valid_invoice?
    ii = InvoiceItem.where(item_id: id)
    if ii.count == 1
      i = Invoice.where(id: ii[0].id)
      { id: i[0].id } if i[0].invoice_items.count == 1
    end
  end

  def self.search_items(data, count = nil)
    if data[0] == "name"
      Item.search_by_name(data[1], count)
    elsif data[0] == "between"
      Item.search_between_price(data[1], data[2], count)
    elsif data[0] == "min"
      Item.search_min_price(data[1], count)
    elsif data[0] == "max"
      Item.search_max_price(data[1], count)
    end
  end

  def self.search_by_name(name, count)
    if count.nil? 
      Item.where('name ILIKE ?', "%#{name}%").order(name: :asc)
    else 
      Item.where('name ILIKE ?', "%#{name}%").order(name: :asc).limit(count)
    end
  end

  def self.search_between_price(min, max, count)
    if count.nil? 
      Item.where("unit_price between #{min} and #{max}").order(name: :asc)
    else 
      Item.where("unit_price between #{min} and #{max}").order(name: :asc).limit(1)
    end
  end
  
  def self.search_min_price(min, count)
    if count.nil? 
      Item.where("unit_price >= #{min}").order(name: :asc)
    else 
      Item.where("unit_price >= #{min}").order(name: :asc).limit(1)
    end
  end

  def self.search_max_price(max, count)
    if count.nil? 
      Item.where("unit_price <= #{max}").order(name: :asc)
    else 
      Item.where("unit_price <= #{max}").order(name: :asc).limit(1)
    end
  end
end
