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
      if i[0].invoice_items.count == 1
        {id: i[0].id}
      else 
        nil 
      end
    end
  end

  def self.name_search(name)
    Item.where("name ILIKE ?", "%#{name}%").order(name: :asc).limit(1)
  end

  def self.find_all_by_name(name)
    Item.where("name ILIKE ?", "%#{name}%").order(name: :asc)
  end

  def self.price_search(min, max)
    if min == nil 
      Item.where("unit_price between 0 and #{max}").order(name: :asc).limit(1)
    elsif max == nil 
      Item.where("unit_price between #{min} and 999999").order(name: :asc).limit(1)
    else
      Item.where("unit_price between #{min} and #{max}").order(name: :asc).limit(1)
    end
  end

  def self.find_all_by_price(min, max)
     if min == nil 
      Item.where("unit_price between 0 and #{max}").order(name: :asc)
    elsif max == nil 
      Item.where("unit_price between #{min} and 999999").order(name: :asc)
    else
      Item.where("unit_price between #{min} and #{max}").order(name: :asc)
    end
  end


end