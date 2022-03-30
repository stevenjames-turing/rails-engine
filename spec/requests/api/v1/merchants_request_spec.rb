require 'rails_helper'

describe "Merchants API" do
  context 'Merchans#index' do 
    it 'sends a list of merchants' do
      create_list(:merchant, 3)
  
      get '/api/v1/merchants'
  
      expect(response).to be_successful
  
      merchants = JSON.parse(response.body, symbolize_names: true)
      expect(merchants[:data].count).to eq(3)
  
      merchants[:data].each do |merchant|  
        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_a String
  
        expect(merchant[:attributes]).to have_key(:name)
        expect(merchant[:attributes][:name]).to be_a String 
      end 
    end

    it 'returns an array of data even if only 1 resource is found' do 
      create(:merchant)
  
      get '/api/v1/merchants'
  
      expect(response).to be_successful
  
      merchants = JSON.parse(response.body, symbolize_names: true)
      expect(merchants[:data]).to be_an Array
  
      expect(merchants[:data].count).to eq(1)
  
      merchants[:data].each do |merchant|  
        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_an String
  
        expect(merchant[:attributes]).to have_key(:name)
        expect(merchant[:attributes][:name]).to be_a String
      end 
    end

    it 'returns an array of data even if no resources are found' do 
      get '/api/v1/merchants'
  
      expect(response).to be_successful
  
      merchants = JSON.parse(response.body, symbolize_names: true)
      expect(merchants[:data]).to be_an Array
  
      expect(merchants[:data].count).to eq(0)
    end

    it 'does NOT send dependent data of the resource' do 
      create_list(:merchant, 3)
  
      get '/api/v1/merchants'
  
      expect(response).to be_successful
  
      merchants = JSON.parse(response.body, symbolize_names: true)

      merchants[:data].each do |merchant|  
        expect(merchant.keys.count).to eq(3)
        expect(merchant.keys).to eq([:id, :type, :attributes])
        
        expect(merchant.keys).to_not include(:relationships)

        expect(merchant[:attributes].keys.count).to eq(1)
        expect(merchant[:attributes].keys).to eq([:name])
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
      
      expect(merchant[:data]).to have_key(:id)
      expect(merchant[:data][:id]).to eq(id.to_s)
      expect(merchant[:data][:id]).to_not eq(id2.to_s)
      
      expect(merchant[:data][:attributes]).to have_key(:name)
      expect(merchant[:data][:attributes][:name]).to be_a String 
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
      expect(merchant_items[:data].count).to eq(2)
      expect(merchant_items[:data].first[:id]).to eq(item1.id.to_s)
      expect(merchant_items[:data].last[:id]).to eq(item2.id.to_s)
  
      merchant_items[:data].each do |item| 
        expect(item).to have_key(:id)
        expect(item[:id]).to be_an String
  
        expect(item[:attributes]).to have_key(:merchant_id)
        expect(item[:attributes][:merchant_id]).to be_an Integer
  
        expect(item[:attributes]).to have_key(:name)
        expect(item[:attributes][:name]).to be_a String
  
        expect(item[:attributes]).to have_key(:description)
        expect(item[:attributes][:description]).to be_a String
  
        expect(item[:attributes]).to have_key(:unit_price)
        expect(item[:attributes][:unit_price]).to be_a Float
      end
    end 

    it 'returns a status 404 if merchant is not found' do 
      merchant = create(:merchant, id: 1)
      
      item1 = create(:item, merchant_id: merchant.id)
      item2 = create(:item, merchant_id: merchant.id)
      
      get "/api/v1/merchants/28/items"
      
      expect(response).to have_http_status(404)
    end
  end

  context 'Merchants#find' do 
    context 'name parameter' do 
      it 'should return a single object' do 
        create_list(:merchant, 3)
        create(:merchant, name: "Schitt's Creek")

        get "/api/v1/merchants/find?name=Creek"
        expect(response).to be_successful

        merchants = JSON.parse(response.body, symbolize_names: true)
        expect(merchants.count).to eq(1)
    
        expect(merchants[:data][:attributes]).to have_key(:name)
        expect(merchants[:data][:attributes][:name]).to eq("Schitt's Creek")
      end

      it 'should return the first object in case-sensitive alphabetical order if multiple matches are found' do 
        merchant1 = create(:merchant, name: "Schitt's Creek")
        merchant2 = create(:merchant, name: "Knob Creek")
        
        get "/api/v1/merchants/find?name=creek"

        expect(response).to be_successful
        
        merchants = JSON.parse(response.body, symbolize_names: true)

        expect(merchants.count).to eq(1)
  
        expect(merchants[:data][:attributes]).to have_key(:name)
        expect(merchants[:data][:attributes][:name]).to eq("Knob Creek")
      end
    end
  end
  context 'Merchants#find_all' do 
    context 'name parameter' do 
      
    end
  end 
end