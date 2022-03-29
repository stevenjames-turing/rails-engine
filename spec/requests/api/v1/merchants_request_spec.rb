require 'rails_helper'

describe "Merchants API" do
  context 'Merchans#index' do 
    it 'sends a list of merchants' do
      create_list(:merchant, 3)
  
      get '/api/v1/merchants'
  
      expect(response).to be_successful
  
      merchants = JSON.parse(response.body, symbolize_names: true)
  
      expect(merchants.count).to eq(3)
  
      merchants.each do |merchant|  
        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_an Integer
  
        expect(merchant).to have_key(:name)
        expect(merchant[:name]).to be_a String 
      end 
    end

    it 'returns an array of data even if only 1 resource is found' do 
      create(:merchant)
  
      get '/api/v1/merchants'
  
      expect(response).to be_successful
  
      merchants = JSON.parse(response.body, symbolize_names: true)
      expect(merchants).to be_an Array
  
      expect(merchants.count).to eq(1)
  
      merchants.each do |merchant|  
        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_an Integer
  
        expect(merchant).to have_key(:name)
        expect(merchant[:name]).to be_a String
      end 
    end
  end

  context 'Merchants#show' do 
    it 'can get one merchant by its id' do 
      id = create(:merchant).id 
      id2 = create(:merchant).id 
  
      get "/api/v1/merchants/#{id}"
  
      merchant = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to be_successful
      
      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to eq(id)
      expect(merchant[:id]).to_not eq(id2)
      
      expect(merchant).to have_key(:name)
      expect(merchant[:name]).to be_a String 
    end
  end

  context 'Merchants/Items#index' do 
    it 'can get all items for a given merchant' do 
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      
      item1 = create(:item, merchant_id: merchant1.id)
      item2 = create(:item, merchant_id: merchant1.id)
      item3 = create(:item, merchant_id: merchant2.id)
      
      get "/api/v1/merchants/#{merchant1.id}/items"
      
      merchant_items = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to be_successful
      
      expect(Item.count).to eq(3)
      expect(merchant_items.count).to eq(2)
      expect(merchant_items.first[:id]).to eq(item1.id)
      expect(merchant_items.last[:id]).to eq(item2.id)
  
      merchant_items.each do |item| 
        expect(item).to have_key(:id)
        expect(item[:id]).to be_an Integer
  
        expect(item).to have_key(:merchant_id)
        expect(item[:merchant_id]).to be_an Integer
  
        expect(item).to have_key(:name)
        expect(item[:name]).to be_a String
  
        expect(item).to have_key(:description)
        expect(item[:description]).to be_a String
  
        expect(item).to have_key(:unit_price)
        expect(item[:unit_price]).to be_a Float
      end
    end 
  end
end