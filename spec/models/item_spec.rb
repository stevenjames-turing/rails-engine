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
  end
  describe 'class methods' do 
    describe '#search_items(data, count = nil)' do
      context 'determines proper search type and passes data to SeachHelper module methods' do 
        it 'passes name data to SearchHelper#search_by_name' do 
          expect(Item.search_items(["name", "creek"])).to eq([@item2, @item1])
        end
        it 'passes min price data to SearchHelper#search_min_price' do 
          expect(Item.search_items(["min", 5])).to eq([@item1, @item3])
        end
        it 'passes max price data to SearchHelper#search_max_price' do 
          expect(Item.search_items(["max", 5])).to eq([@item2])
        end
        it 'passes min and max price data to SearchHelper#search_between price' do 
          expect(Item.search_items(["between", 3, 9])).to eq([@item2, @item1])
        end
      end
    end

  end
  describe 'instance methods' do 
    describe '.valid_invoice?' do 
      before(:each) do 
        @merchant = create(:merchant)
        @customer = create(:customer)
        @invoice1 = create(:invoice, merchant_id: @merchant.id, customer_id: @customer.id)
        @invoice2 = create(:invoice, merchant_id: @merchant.id, customer_id: @customer.id)
        @invoice_item1 = create(:invoice_item, invoice_id: @invoice1.id, item_id: @item1.id, unit_price: @item1.unit_price)
        @invoice_item2 = create(:invoice_item, invoice_id: @invoice1.id, item_id: @item3.id, unit_price: @item3.unit_price)
        @invoice_item3 = create(:invoice_item, invoice_id: @invoice2.id, item_id: @item2.id, unit_price: @item2.unit_price)
      end
      
      it 'finds invoice item and returns invoice if invoice has only 1 item' do 
        expect(@item2.valid_invoice?).to eq({id: @invoice2.id})
      end
      
      it 'finds invoice item and returns blank array if invoice has more than 1 item' do 
        expect(@item1.valid_invoice?).to eq(nil)
      end
    end
  end
end
