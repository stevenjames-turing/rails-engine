require 'rails_helper'

RSpec.describe SearchHelper do
  describe 'module methods' do 
    before(:each) do 
      @merchant1 = create(:merchant, name: "Sierra Nevada")
      @merchant2 = create(:merchant, name: "This Sierra")
      @item1 = create(:item, name: "Knob Creek", unit_price: 3.25)
      @item2 = create(:item, name: "Schitt's Creek", unit_price: 8.25)
      @item3 = create(:item, name: "Creeky Lodge", unit_price: 11.28)
      @item4 = create(:item, name: "This Item", unit_price: 10)
    end

    describe '#search_by_name(data, count = nil)' do
      it 'searches by name and returns a single object (first object in alphabetical order if multiples)' do
        expect(Merchant.search_by_name("Sierra", 1)).to eq([@merchant1])
        expect(Merchant.search_by_name("Sierra", 1)[0].name).to eq("Sierra Nevada")
      end

      it 'searches by name and returns all objects' do 
        expect(Item.search_by_name("creek")).to eq([@item3, @item1, @item2])
        expect(Item.search_by_name("creek")).to_not include(@item4)
      end
    end
    
  end
end
