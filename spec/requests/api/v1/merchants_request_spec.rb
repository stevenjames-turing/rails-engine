require 'rails_helper'

describe 'Merchants API' do
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
        expect(merchant.keys).to eq(%i[id type attributes])

        expect(merchant.keys).to_not include(:relationships)

        expect(merchant[:attributes].keys.count).to eq(1)
        expect(merchant[:attributes].keys).to eq([:name])
      end
    end

    context 'pagination' do 
      it 'returns the first 20 objects if no params are given' do 
        create_list(:merchant, 50)

        get '/api/v1/merchants'

        expect(response).to be_successful

        merchants = JSON.parse(response.body, symbolize_names: true)
        expect(merchants[:data]).to be_an Array

        expect(merchants[:data].count).to eq(20)
      end

      it 'returns the number of objects passed in params' do 
        create_list(:merchant, 50)

        get '/api/v1/merchants?per_page=35'

        expect(response).to be_successful

        merchants = JSON.parse(response.body, symbolize_names: true)
        expect(merchants[:data]).to be_an Array

        expect(merchants[:data].count).to eq(35)
      end

      it 'will return the next 20 objects if given a page number param' do 
        create_list(:merchant, 50)
  
        get '/api/v1/merchants?page=1'
        
        first_20_merchants = JSON.parse(response.body, symbolize_names: true)
        
        get '/api/v1/merchants?page=2'
        
        next_20_merchants = JSON.parse(response.body, symbolize_names: true)
  
        expect(next_20_merchants[:data].count).to eq(20)

        next_20_merchants.each do |merchant|
          expect(first_20_merchants.include?(merchant)).to be false
        end
      end

      it 'returns if page and per_page params are passed together' do 
        create_list(:merchant, 50)

        get '/api/v1/merchants?per_page=15&page=3'

        expect(response).to be_successful

        merchants = JSON.parse(response.body, symbolize_names: true)
        expect(merchants[:data]).to be_an Array

        expect(merchants[:data].count).to eq(15)
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

    it 'returns a 404 error if ID not found' do 
      id = create(:merchant).id
      id2 = create(:merchant).id

      get "/api/v1/merchants/987654321"

      merchant = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(404)
    end
    
    it 'returns a 404 error is string passed as ID' do 
      id = create(:merchant).id
      id2 = create(:merchant).id

      get "/api/v1/merchants/'string'"

      merchant = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(404)
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

      get '/api/v1/merchants/28/items'

      expect(response).to have_http_status(404)
    end

    it 'will return an error if string passed as Item ID' do 
      merchant = create(:merchant, id: 1)

      item1 = create(:item, merchant_id: merchant.id)
      item2 = create(:item, merchant_id: merchant.id)

      get "/api/v1/merchants/'string'/items"

      expect(response).to have_http_status(404)
    end
  end

  context 'Merchants#find' do
    context 'name parameter' do
      it 'should return a single object' do
        create_list(:merchant, 3)
        create(:merchant, name: "Schitt's Creek")

        get '/api/v1/merchants/find?name=Creek'
        expect(response).to be_successful

        merchants = JSON.parse(response.body, symbolize_names: true)
        expect(merchants.count).to eq(1)

        expect(merchants[:data][:attributes]).to have_key(:name)
        expect(merchants[:data][:attributes][:name]).to eq("Schitt's Creek")
      end

      it 'should return the first object in case-sensitive alphabetical order if multiple matches are found' do
        merchant1 = create(:merchant, name: "Schitt's Creek")
        merchant2 = create(:merchant, name: 'Knob Creek')

        get '/api/v1/merchants/find?name=creek'

        expect(response).to be_successful

        merchants = JSON.parse(response.body, symbolize_names: true)

        expect(merchants.count).to eq(1)

        expect(merchants[:data][:attributes]).to have_key(:name)
        expect(merchants[:data][:attributes][:name]).to eq('Knob Creek')
      end

      it 'returns even if given a partial name' do 
        merchant1 = create(:merchant, name: "Schitt's Creek")
        merchant2 = create(:merchant, name: 'Knob Creek')

        get '/api/v1/merchants/find?name=nob'

        expect(response).to be_successful

        merchants = JSON.parse(response.body, symbolize_names: true)

        expect(merchants.count).to eq(1)

        expect(merchants[:data][:attributes]).to have_key(:name)
        expect(merchants[:data][:attributes][:name]).to eq('Knob Creek')
      end

      it 'does not return anything if no fragment matches' do 
        merchant1 = create(:merchant, name: "Schitt's Creek")
        merchant2 = create(:merchant, name: 'Knob Creek')

        get '/api/v1/merchants/find?name=col'

        merchants = JSON.parse(response.body, symbolize_names: true)

        expect(merchants[:data][:message]).to eq("No matching merchant")
      end

      it 'should return an error if search param is missing' do 
        merchant1 = create(:merchant, name: "Schitt's Creek")
        merchant2 = create(:merchant, name: 'Knob Creek')

        get '/api/v1/merchants/find?'

        merchants = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(400)
      end

      it 'should return an error if search param is empty' do
        merchant1 = create(:merchant, name: "Schitt's Creek")
        merchant2 = create(:merchant, name: 'Knob Creek')

        get '/api/v1/merchants/find?name='

        merchants = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(400)
      end 
    end
  end

  context 'Merchants#find_all' do
    context 'name parameter' do
      it 'should return an array of objects' do
        merchant1 = create(:merchant, name: "Schitt's Creek")
        merchant2 = create(:merchant, name: 'Knob Creek')

        get '/api/v1/merchants/find_all?name=creek'

        expect(response).to be_successful

        merchants = JSON.parse(response.body, symbolize_names: true)

        expect(merchants[:data].count).to eq(2)

        expect(merchants[:data][0][:attributes][:name]).to eq('Knob Creek')
        expect(merchants[:data][-1][:attributes][:name]).to eq("Schitt's Creek")
      end

      it 'should not return a 404 if no objects are found' do
        merchant1 = create(:merchant, name: "Schitt's Creek")
        merchant2 = create(:merchant, name: 'Knob Creek')

        get '/api/v1/merchants/find_all?name=turing'

        merchants = JSON.parse(response.body, symbolize_names: true)

        expect(response).to_not have_http_status(404)
      end

      it 'should return an error if search param is missing' do 
       merchant1 = create(:merchant, name: "Schitt's Creek")
        merchant2 = create(:merchant, name: 'Knob Creek')

        get '/api/v1/merchants/find?'

        merchants = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(400)
      end

      it 'should return an error if search param is empty' do
        merchant1 = create(:merchant, name: "Schitt's Creek")
        merchant2 = create(:merchant, name: 'Knob Creek')

        get '/api/v1/merchants/find?name='

        merchants = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(400)
      end 
    end
  end
end
