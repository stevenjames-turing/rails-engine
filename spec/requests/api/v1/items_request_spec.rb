require 'rails_helper'

describe "Items API" do
  context 'Item#index' do
    it 'sends a list of items' do
      create_list(:item, 3)
  
      get '/api/v1/items'
  
      expect(response).to be_successful
  
      items = JSON.parse(response.body, symbolize_names: true)
      expect(items[:data]).to be_an Array
  
      expect(items[:data].count).to eq(3)
  
      items[:data].each do |item|  
        expect(item).to have_key(:id)
        expect(item[:id]).to be_a String
  
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

    it 'returns an array of data even if only 1 resource is found' do 
      create(:item)
  
      get '/api/v1/items'
  
      expect(response).to be_successful
  
      items = JSON.parse(response.body, symbolize_names: true)
      expect(items[:data]).to be_an Array
  
      expect(items[:data].count).to eq(1)
  
      items[:data].each do |item|  
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

    it 'returns an array of data even if no resources are found' do 
      get '/api/v1/items'
  
      expect(response).to be_successful
  
      items = JSON.parse(response.body, symbolize_names: true)
      expect(items[:data]).to be_an Array
  
      expect(items[:data].count).to eq(0)
    end

    it 'does NOT send dependent data of the resource' do 
      create_list(:item, 3)
  
      get '/api/v1/items'
  
      expect(response).to be_successful
  
      items = JSON.parse(response.body, symbolize_names: true)
  
      items[:data].each do |item|
        expect(item.keys.count).to eq(3)
        expect(item.keys).to eq([:id, :type, :attributes])

        expect(item.keys).to_not include(:relationships)

        expect(item[:attributes].keys.count).to eq(4)
        expect(item[:attributes].keys).to eq([:name, :description, :unit_price, :merchant_id])
      end 
    end
  end

  context 'Items#show' do
    it 'can get one item by its ID' do 
      id = create(:item).id 
      id2 = create(:item).id 

      get "/api/v1/items/#{id}"

      item = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      
      expect(item[:data]).to have_key(:id)
      expect(item[:data][:id]).to be_a String
      expect(item[:data][:id]).to eq(id.to_s)
      expect(item[:data][:id]).to_not eq(id2.to_s)
      
      expect(item[:data][:attributes]).to have_key(:name)
      expect(item[:data][:attributes][:name]).to be_a String 

      expect(item[:data][:attributes]).to have_key(:merchant_id)
      expect(item[:data][:attributes][:merchant_id]).to be_an Integer

      expect(item[:data][:attributes]).to have_key(:description)
      expect(item[:data][:attributes][:description]).to be_a String

      expect(item[:data][:attributes]).to have_key(:unit_price)
      expect(item[:data][:attributes][:unit_price]).to be_a Float
    end
  end

  context 'Items#create' do 
    it 'can create a new item' do 
      merchant = create(:merchant, id: 14)
      item_params = ({
                      "name": "value1",
                      "description": "value2",
                      "unit_price": 100.99,
                      "merchant_id": 14
                    })
      headers = {"CONTENT_TYPE" => "application/json"}
  
      post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
      created_item = Item.last
  
      expect(response).to be_successful
      expect(created_item.merchant_id).to eq(item_params[:merchant_id])
      expect(created_item.name).to eq(item_params[:name])
      expect(created_item.description).to eq(item_params[:description])
      expect(created_item.unit_price).to eq(item_params[:unit_price])
    end

    it 'returns an error if any attribute is missing' do 
      merchant = create(:merchant, id: 14)
      item_params = ({
                      "name": "value1",
                      "description": "value2",
                      "merchant_id": 14
                    })
      headers = {"CONTENT_TYPE" => "application/json"}
  
      post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
      
      expect(response.body).to eq("Error, invalid input.")
      expect(response).to be_successful
    end

    it 'ignores any attributes sent by user that are not allowed' do 
      merchant = create(:merchant)
      item_params = ({
                      merchant_id: merchant.id, 
                      name: 'Ethiopia Limu Gera', 
                      description: 'Single origin coffee', 
                      unit_price: 12.99, 
                      variety: "Heirloom Ethiopian", 
                      region: "Djimma"
                    })
      headers = {"CONTENT_TYPE" => "application/json"}
  
      post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

      created_item = Item.last
      expect(response).to be_successful
      expect{created_item.variety}.to raise_error(NoMethodError)
      expect{created_item.region}.to raise_error(NoMethodError)
      expect(created_item.merchant_id).to eq(item_params[:merchant_id])
      expect(created_item.name).to eq(item_params[:name])
      expect(created_item.description).to eq(item_params[:description])
      expect(created_item.unit_price).to eq(item_params[:unit_price])
    end
  end

  context 'Items#update' do 
    it 'can update 1 attribute of an existing item' do 
      merchant = create(:merchant)
      id = create(:item, merchant_id: merchant.id).id
      previous_name = Item.last.name 
      item_params = { name: "Ethiopia Limu Gera" }
      headers = {"CONTENT_TYPE" => "application/json"}
  
      patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: item_params})
      item = Item.find_by(id: id)
  
      expect(response).to be_successful
      expect(item.name).to_not eq(previous_name)
      expect(item.name).to eq("Ethiopia Limu Gera")
    end

    it 'can update 2 or more attributes of an existing item' do 
      merchant = create(:merchant)
      id = create(:item, merchant_id: merchant.id).id
      previous_name = Item.last.name 
      previous_description = Item.last.description
      item_params = { 
                      name: "Ethiopia Limu Gera",
                      description: 'Single origin coffee'}
      headers = {"CONTENT_TYPE" => "application/json"}
        
      patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: item_params})
      item = Item.find_by(id: id)

      expect(response).to be_successful
      expect(item.name).to_not eq(previous_name)
      expect(item.name).to eq("Ethiopia Limu Gera")

      expect(item.description).to_not eq(previous_description)
      expect(item.description).to eq('Single origin coffee')
    end
  end

  context 'Items#destroy' do 
    xit 'can destroy a item' do 
      item = create(:item)
  
      expect(Item.count).to eq(1) 
  
      delete "/api/v1/items/#{item.id}"
  
      expect(response).to be_successful
      expect(Item.count).to eq(0)
      expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
    end

    xit 'returns no body and status 204 when item is destroyed' do 
      item = create(:item)
  
      expect(Item.count).to eq(1) 
  
      delete "/api/v1/items/#{item.id}"

      expect(response.body).to eq("") 
      expect(response).to have_http_status(204)
    end
  end

  context 'Items/Merchants#index' do 
    xit 'can get the merchant info for an item with item ID' do 
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      
      item1 = create(:item, merchant_id: merchant1.id)
      item2 = create(:item, merchant_id: merchant2.id)
      
      get "/api/v1/items/#{item1.id}/merchants"
      
      item_merchant = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to be_successful
      
      expect(item_merchant).to have_key(:id)
      expect(item_merchant[:id]).to eq(merchant1.id)
      expect(item_merchant[:id]).to_not eq(merchant2.id)
      
      expect(item_merchant).to have_key(:name)
      expect(item_merchant[:name]).to eq(merchant1.name)
      expect(item_merchant[:name]).to be_a String 
    end

    xit 'returns a status 404 if item is not found' do 
      merchant = create(:merchant, id: 1)
  
      item = create(:item, merchant_id: merchant.id, id: 1)
      
      get "/api/v1/items/28/merchants"
      
      expect(response).to have_http_status(404)
    end
  end
end 