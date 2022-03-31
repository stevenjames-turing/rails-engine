require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :unit_price }
    it { should validate_presence_of :merchant_id }
  end
  describe 'relationships' do
    it { should have_many(:invoices).through(:invoice_items) }
    it { should belong_to :merchant }
  end
  before(:each) do 
    @item1 = create(:item, name: "Schitt's Creek", unit_price: 8.25)
    @item2 = create(:item, name: "Knob Creek", unit_price: 3.25)
    @item3 = create(:item, name: "This Item", unit_price: 10)
    @merchant = create(:merchant)
    @customer = create(:customer)
    @invoice = create(:invoice, merchant_id: @merchant.id, customer_id: @customer.id)
    @invoice_item = create(:invoice_item, invoice_id: @invoice.id, item_id: @item1.id, unit_price: @item1.unit_price)
    @invoice_item = create(:invoice_item, invoice_id: @invoice.id, item_id: @item3.id, unit_price: @item3.unit_price)
  end
  describe 'class methods' do 
    describe '#search_items(data, count = nil)' do
      context 'determines proper search type and passes data to SeachHelper module methods' do 
        it 'passes name data to SearchHelper#search_by_name' do 
          expect(Item.search_items(["name", "creek"])).to eq([@item2, @item1])
        end
        it 'passes min price data to SearchHelper#search_min_price' do 
        end
        it 'passes max price data to SearchHelper#search_max_price' do 

        end
        it 'passes min and max price data to SearchHelper#search_between price' do 

        end
      end
    end

  end
  describe 'instance methods' do 
    describe '.valid_invoice?' do 
      it 'finds invoice item and returns count of items on an invoice' do 
        
      end
    end
  end
end
