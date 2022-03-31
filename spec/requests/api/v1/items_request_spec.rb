require 'rails_helper'

describe 'Items API' do
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
        expect(item.keys).to eq(%i[id type attributes])

        expect(item.keys).to_not include(:relationships)

        expect(item[:attributes].keys.count).to eq(4)
        expect(item[:attributes].keys).to eq(%i[name description unit_price merchant_id])
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

    it 'returns a 404 error if ID not found' do 
      item1 = create(:item)
      item2 = create(:item)

      get "/api/v1/items/987654"

      item = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(404)
    end
    
    it 'returns a 404 error is string passed as ID' do 
      item1 = create(:item)
      item2 = create(:item)
  
      get "/api/v1/items/'thiswontwork'"
  
      item = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to have_http_status(404)
    end
  end

  context 'Items#create' do
    it 'can create a new item' do
      merchant = create(:merchant, id: 14)
      item_params = {
        "name": 'value1',
        "description": 'value2',
        "unit_price": 100.99,
        "merchant_id": 14
      }
      headers = { 'CONTENT_TYPE' => 'application/json' }

      post '/api/v1/items', headers: headers, params: JSON.generate(item: item_params)
      created_item = Item.last

      expect(response).to be_successful
      expect(created_item.merchant_id).to eq(item_params[:merchant_id])
      expect(created_item.name).to eq(item_params[:name])
      expect(created_item.description).to eq(item_params[:description])
      expect(created_item.unit_price).to eq(item_params[:unit_price])
    end

    it 'returns an error if any attribute is missing' do
      merchant = create(:merchant, id: 14)
      item_params = {
        "name": 'value1',
        "description": 'value2',
        "merchant_id": 14
      }
      headers = { 'CONTENT_TYPE' => 'application/json' }

      post '/api/v1/items', headers: headers, params: JSON.generate(item: item_params)

      expect(response.body).to eq('Error, invalid input.')
      expect(response).to be_successful
    end

    it 'ignores any attributes sent by user that are not allowed' do
      merchant = create(:merchant)
      item_params = {
        merchant_id: merchant.id,
        name: 'Ethiopia Limu Gera',
        description: 'Single origin coffee',
        unit_price: 12.99,
        variety: 'Heirloom Ethiopian',
        region: 'Djimma'
      }
      headers = { 'CONTENT_TYPE' => 'application/json' }

      post '/api/v1/items', headers: headers, params: JSON.generate(item: item_params)

      created_item = Item.last
      expect(response).to be_successful
      expect { created_item.variety }.to raise_error(NoMethodError)
      expect { created_item.region }.to raise_error(NoMethodError)
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
      item_params = { name: 'Ethiopia Limu Gera' }
      headers = { 'CONTENT_TYPE' => 'application/json' }

      patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({ item: item_params })
      item = Item.find_by(id: id)

      expect(response).to be_successful
      expect(item.name).to_not eq(previous_name)
      expect(item.name).to eq('Ethiopia Limu Gera')
    end

    it 'can update 2 or more attributes of an existing item' do
      merchant = create(:merchant)
      id = create(:item, merchant_id: merchant.id).id
      previous_name = Item.last.name
      previous_description = Item.last.description
      item_params = {
        name: 'Ethiopia Limu Gera',
        description: 'Single origin coffee'
      }
      headers = { 'CONTENT_TYPE' => 'application/json' }
      
      patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({ item: item_params })
      item = Item.find_by(id: id)
      
      expect(response).to be_successful
      expect(item.name).to_not eq(previous_name)
      expect(item.name).to eq('Ethiopia Limu Gera')
      
      expect(item.description).to_not eq(previous_description)
      expect(item.description).to eq('Single origin coffee')
    end
    
    it 'will return an error if merchant ID does not exist' do 
      merchant = create(:merchant)
      id = create(:item, merchant_id: merchant.id).id
      previous_name = Item.last.name
      previous_description = Item.last.description
      item_params = {
        name: 'Ethiopia Limu Gera',
        description: 'Single origin coffee',
        merchant_id: 999938383837
      }
      headers = { 'CONTENT_TYPE' => 'application/json' }

      patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({ item: item_params })

      expect(response).to have_http_status(404)
    end
    
    it 'will return an error if item ID does not exist' do 
      merchant = create(:merchant)
      id = create(:item, merchant_id: merchant.id).id
      previous_name = Item.last.name
      previous_description = Item.last.description
      item_params = {
        name: 'Ethiopia Limu Gera',
        description: 'Single origin coffee',
        merchant_id: 999938383837
      }
      headers = { 'CONTENT_TYPE' => 'application/json' }
      
      patch "/api/v1/items/987654", headers: headers, params: JSON.generate({ item: item_params })
      
      expect(response).to have_http_status(404)
    end
  
    it 'will return an error if string passed as item id' do 
       merchant = create(:merchant)
      id = create(:item, merchant_id: merchant.id).id
      previous_name = Item.last.name
      previous_description = Item.last.description
      item_params = {
        name: 'Ethiopia Limu Gera',
        description: 'Single origin coffee',
        merchant_id: 999938383837
      }
      headers = { 'CONTENT_TYPE' => 'application/json' }

      patch "/api/v1/items/'thiswontwork'", headers: headers, params: JSON.generate({ item: item_params })

      expect(response).to have_http_status(404)
    end
  end

  context 'Items#destroy' do
    it 'can destroy a item' do
      item = create(:item)

      expect(Item.count).to eq(1)

      delete "/api/v1/items/#{item.id}"

      expect(response).to be_successful
      expect(Item.count).to eq(0)
      expect { Item.find(item.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns no body and status 204 when item is destroyed' do
      item = create(:item)

      expect(Item.count).to eq(1)

      delete "/api/v1/items/#{item.id}"

      expect(response.body).to eq('')
      expect(response).to have_http_status(204)
    end

    it 'destroys an invoice if this was the only item on invoice' do
      merchant = create(:merchant)
      customer = create(:customer)
      item = create(:item)
      invoice = create(:invoice, merchant_id: merchant.id, customer_id: customer.id)
      invoice_item = create(:invoice_item, invoice_id: invoice.id, item_id: item.id, unit_price: item.unit_price)

      expect(Item.count).to eq(1)
      expect(Invoice.count).to eq(1)
      expect(InvoiceItem.count).to eq(1)

      delete "/api/v1/items/#{item.id}"

      expect(Item.count).to eq(0)
      expect(Invoice.count).to eq(0)
      expect(InvoiceItem.count).to eq(0)

      expect(response.body).to eq('')
      expect(response).to have_http_status(204)
    end

    it 'does NOT destroy an invoice if this was NOT the only item on invoice' do
      merchant = create(:merchant)
      customer = create(:customer)
      item1 = create(:item)
      item2 = create(:item)
      invoice = create(:invoice, merchant_id: merchant.id, customer_id: customer.id)
      invoice_item = create(:invoice_item, invoice_id: invoice.id, item_id: item1.id, unit_price: item1.unit_price)
      invoice_item = create(:invoice_item, invoice_id: invoice.id, item_id: item2.id, unit_price: item2.unit_price)

      expect(Item.count).to eq(2)
      expect(Invoice.count).to eq(1)
      expect(InvoiceItem.count).to eq(2)

      delete "/api/v1/items/#{item1.id}"

      expect(Item.count).to eq(1)
      expect(Invoice.count).to eq(1)
      expect(InvoiceItem.count).to eq(1)

      expect(response.body).to eq('')
      expect(response).to have_http_status(204)
    end
  end

  context 'Items/Merchants#index' do
    it 'can get the merchant info for an item with item ID' do
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)

      item1 = create(:item, merchant_id: merchant1.id)
      item2 = create(:item, merchant_id: merchant2.id)

      get "/api/v1/items/#{item1.id}/merchant"

      item_merchant = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful

      expect(item_merchant[:data]).to have_key(:id)
      expect(item_merchant[:data][:id]).to eq(merchant1.id.to_s)
      expect(item_merchant[:data][:id]).to_not eq(merchant2.id.to_s)

      expect(item_merchant[:data][:attributes]).to have_key(:name)
      expect(item_merchant[:data][:attributes][:name]).to eq(merchant1.name)
      expect(item_merchant[:data][:attributes][:name]).to be_a String
    end

    it 'returns an error if item ID does not exist' do 
      merchant = create(:merchant)
      customer = create(:customer)
      item1 = create(:item)
      item2 = create(:item)
      invoice = create(:invoice, merchant_id: merchant.id, customer_id: customer.id)
      invoice_item = create(:invoice_item, invoice_id: invoice.id, item_id: item1.id, unit_price: item1.unit_price)
      invoice_item = create(:invoice_item, invoice_id: invoice.id, item_id: item2.id, unit_price: item2.unit_price)

      get "/api/v1/items/987654321/merchant"

      expect(response).to have_http_status(404)
    end

    it 'will return an error if string passed as Item ID' do 
      merchant = create(:merchant)
      customer = create(:customer)
      item1 = create(:item)
      item2 = create(:item)
      invoice = create(:invoice, merchant_id: merchant.id, customer_id: customer.id)
      invoice_item = create(:invoice_item, invoice_id: invoice.id, item_id: item1.id, unit_price: item1.unit_price)
      invoice_item = create(:invoice_item, invoice_id: invoice.id, item_id: item2.id, unit_price: item2.unit_price)

      get "/api/v1/items/'string'/merchant"

      expect(response).to have_http_status(404)
    end
  end

  context 'Items#find' do
    context 'name parameter' do
      it 'should return a single object' do
        create_list(:item, 3)
        create(:item, name: "Schitt's Creek")

        get '/api/v1/items/find?name=Creek'
        expect(response).to be_successful

        items = JSON.parse(response.body, symbolize_names: true)
        expect(items.count).to eq(1)

        expect(items[:data][:attributes]).to have_key(:name)
        expect(items[:data][:attributes][:name]).to eq("Schitt's Creek")
      end

      it 'should return the first object in case-sensitive alphabetical order if multiple matches are found' do
        item1 = create(:item, name: "Schitt's Creek")
        item2 = create(:item, name: 'Knob Creek')
        get '/api/v1/items/find?name=creek'

        expect(response).to be_successful

        items = JSON.parse(response.body, symbolize_names: true)

        expect(items.count).to eq(1)

        expect(items[:data][:attributes]).to have_key(:name)
        expect(items[:data][:attributes][:name]).to eq('Knob Creek')
      end

      it 'returns even if given a partial name' do 
        item1 = create(:item, name: "Schitt's Creek")
        item2 = create(:item, name: 'Knob Creek')
        get '/api/v1/items/find?name=cre'

        expect(response).to be_successful

        items = JSON.parse(response.body, symbolize_names: true)

        expect(items.count).to eq(1)

        expect(items[:data][:attributes]).to have_key(:name)
        expect(items[:data][:attributes][:name]).to eq('Knob Creek')
      end

      it 'does not return anything if no fragment matches' do 
        item1 = create(:item, name: "Schitt's Creek")
        item2 = create(:item, name: 'Knob Creek')
        get '/api/v1/items/find?name=col'

        items = JSON.parse(response.body, symbolize_names: true)

        expect(items).to have_key(:error)
        expect(items[:error][:message]).to eq("No matching items")
      end

      it 'should return an error if search param is missing' do 
        item1 = create(:item, name: "Schitt's Creek")
        item2 = create(:item, name: 'Knob Creek')

        get '/api/v1/items/find?'

        items = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(400)
      end

      it 'should return an error if search param is empty' do 
        item1 = create(:item, name: "Schitt's Creek")
        item2 = create(:item, name: 'Knob Creek')

        get '/api/v1/items/find?name='

        items = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(400)
      end
    end

    context 'price parameter' do
      context 'min_price' do
        it 'should return a single object' do
          create(:item, unit_price: 3.25)
          create(:item, unit_price: 8.25)
          create(:item, unit_price: 11.28)
          create(:item, unit_price: 20, name: "Schitt's Creek")

          get '/api/v1/items/find?min_price=15'
          expect(response).to be_successful

          items = JSON.parse(response.body, symbolize_names: true)
          expect(items.count).to eq(1)

          expect(items[:data][:attributes]).to have_key(:unit_price)
          expect(items[:data][:attributes][:unit_price]).to eq(20)
          expect(items[:data][:attributes]).to have_key(:name)
          expect(items[:data][:attributes][:name]).to eq("Schitt's Creek")
        end

        it 'should return the first object in case-sensitive alphabetical order if multiple matches are found' do
          create(:item, unit_price: 3.25)
          create(:item, unit_price: 8.25)
          create(:item, unit_price: 11.28)
          create(:item, unit_price: 20, name: "Schitt's Creek")
          create(:item, unit_price: 20, name: 'Knob Creek')

          get '/api/v1/items/find?min_price=15'
          expect(response).to be_successful

          items = JSON.parse(response.body, symbolize_names: true)
          expect(items.count).to eq(1)

          expect(items[:data][:attributes]).to have_key(:unit_price)
          expect(items[:data][:attributes][:unit_price]).to eq(20)
          expect(items[:data][:attributes]).to have_key(:name)
          expect(items[:data][:attributes][:name]).to eq('Knob Creek')
        end

        it 'should return an error if min price less than 0' do 
          item1 = create(:item, unit_price: 3.25, name: 'DEF Item')
          item2 = create(:item, unit_price: 8.25, name: 'CDE Item')
          item3 = create(:item, unit_price: 11.28, name: 'BCD Item')
          item4 = create(:item, unit_price: 20, name: 'ABC Item')

          get '/api/v1/items/find?min_price=-2'

          items = JSON.parse(response.body, symbolize_names: true)

          expect(response).to have_http_status(400)
        end
        
        it 'should return an error if min price param is empty' do 
          item1 = create(:item, unit_price: 3.25, name: 'DEF Item')
          item2 = create(:item, unit_price: 8.25, name: 'CDE Item')
          item3 = create(:item, unit_price: 11.28, name: 'BCD Item')
          item4 = create(:item, unit_price: 20, name: 'ABC Item')

          get '/api/v1/items/find?min_price='

          items = JSON.parse(response.body, symbolize_names: true)

          expect(response).to have_http_status(400)
        end
      end

      context 'max_price' do
        it 'should return a single object' do
          create(:item, unit_price: 3.25)
          create(:item, unit_price: 8.25)
          create(:item, unit_price: 11.28)
          create(:item, unit_price: 2, name: "Schitt's Creek")

          get '/api/v1/items/find?max_price=3'
          expect(response).to be_successful

          items = JSON.parse(response.body, symbolize_names: true)
          expect(items.count).to eq(1)

          expect(items[:data][:attributes]).to have_key(:unit_price)
          expect(items[:data][:attributes][:unit_price]).to eq(2)

          expect(items[:data][:attributes]).to have_key(:name)
          expect(items[:data][:attributes][:name]).to eq("Schitt's Creek")
        end

        it 'should return the first object in case-sensitive alphabetical order if multiple matches are found' do
          create(:item, unit_price: 3.25)
          create(:item, unit_price: 8.25)
          create(:item, unit_price: 11.28)
          create(:item, unit_price: 2, name: "Schitt's Creek")
          create(:item, unit_price: 2, name: 'Knob Creek')

          get '/api/v1/items/find?max_price=3'
          expect(response).to be_successful

          items = JSON.parse(response.body, symbolize_names: true)
          expect(items.count).to eq(1)

          expect(items[:data][:attributes]).to have_key(:unit_price)
          expect(items[:data][:attributes][:unit_price]).to eq(2)

          expect(items[:data][:attributes]).to have_key(:name)
          expect(items[:data][:attributes][:name]).to eq('Knob Creek')
        end

        it 'should return an error if max price less than 0' do 
          item1 = create(:item, unit_price: 3.25, name: 'DEF Item')
          item2 = create(:item, unit_price: 8.25, name: 'CDE Item')
          item3 = create(:item, unit_price: 11.28, name: 'BCD Item')
          item4 = create(:item, unit_price: 20, name: 'ABC Item')

          get '/api/v1/items/find?max_price=-2'

          items = JSON.parse(response.body, symbolize_names: true)

          expect(response).to have_http_status(400)
        end

        it 'should return an error if max price param is empty' do 
          item1 = create(:item, unit_price: 3.25, name: 'DEF Item')
          item2 = create(:item, unit_price: 8.25, name: 'CDE Item')
          item3 = create(:item, unit_price: 11.28, name: 'BCD Item')
          item4 = create(:item, unit_price: 20, name: 'ABC Item')

          get '/api/v1/items/find?max_price='

          items = JSON.parse(response.body, symbolize_names: true)

          expect(response).to have_http_status(400)
        end
      end

      context 'min and max price' do
        it 'should return a single object' do
          create(:item, unit_price: 3.25)
          create(:item, unit_price: 8.25)
          create(:item, unit_price: 11.28)
          create(:item, unit_price: 2, name: "Schitt's Creek")

          get '/api/v1/items/find?min_price=1&max_price=3'
          expect(response).to be_successful

          items = JSON.parse(response.body, symbolize_names: true)
          expect(items.count).to eq(1)

          expect(items[:data][:attributes]).to have_key(:unit_price)
          expect(items[:data][:attributes][:unit_price]).to eq(2)

          expect(items[:data][:attributes]).to have_key(:name)
          expect(items[:data][:attributes][:name]).to eq("Schitt's Creek")
        end

        it 'should return the first object in case-sensitive alphabetical order if multiple matches are found' do
          create(:item, unit_price: 3.25)
          create(:item, unit_price: 8.25)
          create(:item, unit_price: 11.28)
          create(:item, unit_price: 2, name: "Schitt's Creek")
          create(:item, unit_price: 2, name: 'Knob Creek')

          get '/api/v1/items/find?min_price=1&max_price=3'
          expect(response).to be_successful

          items = JSON.parse(response.body, symbolize_names: true)
          expect(items.count).to eq(1)

          expect(items[:data][:attributes]).to have_key(:unit_price)
          expect(items[:data][:attributes][:unit_price]).to eq(2)

          expect(items[:data][:attributes]).to have_key(:name)
          expect(items[:data][:attributes][:name]).to eq('Knob Creek')
        end

        it 'should return an error if min price is greater than max price' do
          create(:item, unit_price: 3.25)
          create(:item, unit_price: 8.25)
          create(:item, unit_price: 11.28)
          create(:item, unit_price: 2, name: "Schitt's Creek")

          get '/api/v1/items/find?min_price=10&max_price=3'

          items = JSON.parse(response.body, symbolize_names: true)

          expect(response).to have_http_status(400)
        end
        
        it 'should return an error if min price is greater than max price' do 
          create(:item, unit_price: 3.25)
          create(:item, unit_price: 8.25)
          create(:item, unit_price: 11.28)
          create(:item, unit_price: 2, name: "Schitt's Creek")
  
          get "/api/v1/items/find?min_price=10&max_price=3"
  
          items = JSON.parse(response.body, symbolize_names: true)

          expect(response).to have_http_status(400)
        end

        it 'should return an error if min price less than 0' do 
          item1 = create(:item, unit_price: 3.25, name: 'DEF Item')
          item2 = create(:item, unit_price: 8.25, name: 'CDE Item')
          item3 = create(:item, unit_price: 11.28, name: 'BCD Item')
          item4 = create(:item, unit_price: 20, name: 'ABC Item')

          get '/api/v1/items/find?min_price=-2&max_price=6'

          items = JSON.parse(response.body, symbolize_names: true)

          expect(response).to have_http_status(400)
        end

      end

      context 'name and price' do
        it 'should return an error if max_price and name parameters are used together' do
          create(:item, unit_price: 3.25)
          create(:item, unit_price: 8.25)
          create(:item, unit_price: 11.28)
          create(:item, unit_price: 2, name: "Schitt's Creek")

          get '/api/v1/items/find?name=creek&max_price=3'

          expect(response).to have_http_status(400)
        end

        it 'should return an error if min_price and name parameters are used together' do
          create(:item, unit_price: 3.25)
          create(:item, unit_price: 8.25)
          create(:item, unit_price: 11.28)
          create(:item, unit_price: 2, name: "Schitt's Creek")

          get '/api/v1/items/find?name=creek&min_price=3'

          expect(response).to have_http_status(400)
        end
      end
    end
  end

  context 'Items#find_all' do
    context 'name parameter' do
      it 'should return an array of objects' do
        item1 = create(:item, name: "Schitt's Creek")
        item2 = create(:item, name: 'Knob Creek')

        get '/api/v1/items/find_all?name=creek'

        expect(response).to be_successful

        items = JSON.parse(response.body, symbolize_names: true)

        expect(items[:data].count).to eq(2)

        expect(items[:data][0][:attributes][:name]).to eq('Knob Creek')
        expect(items[:data][-1][:attributes][:name]).to eq("Schitt's Creek")
      end

      it 'should not return a 404 if no objects are found' do
        item1 = create(:item, name: "Schitt's Creek")
        item2 = create(:item, name: 'Knob Creek')

        get '/api/v1/items/find_all?name=turing'

        items = JSON.parse(response.body, symbolize_names: true)

        expect(response).to_not have_http_status(404)
      end

      it 'should return an error if search param is missing' do 
        item1 = create(:item, name: "Schitt's Creek")
        item2 = create(:item, name: 'Knob Creek')

        get '/api/v1/items/find_all?'

        items = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(400)
      end

      it 'should return an error if search param is empty' do 
        item1 = create(:item, name: "Schitt's Creek")
        item2 = create(:item, name: 'Knob Creek')

        get '/api/v1/items/find_all?name='

        items = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(400)
      end
    end

    context 'price parameter' do
      context 'min_price' do
        it 'should return an array of objects' do
          item1 = create(:item, unit_price: 3.25)
          item2 = create(:item, unit_price: 8.25, name: 'CDE Item')
          item3 = create(:item, unit_price: 11.28, name: 'BCD Item')
          item4 = create(:item, unit_price: 20, name: 'ABC Item')

          get '/api/v1/items/find_all?min_price=5'

          expect(response).to be_successful
          
          items = JSON.parse(response.body, symbolize_names: true)
          
          expect(items[:data].count).to eq(3)
          
          expect(items[:data][0][:attributes][:unit_price]).to eq(20)
          expect(items[:data][1][:attributes][:unit_price]).to eq(11.28)
          expect(items[:data][2][:attributes][:unit_price]).to eq(8.25)
        end
        
        it 'should not return a 404 if no objects are found' do
          item1 = create(:item, unit_price: 3.25)
          item2 = create(:item, unit_price: 8.25, name: 'CDE Item')
          item3 = create(:item, unit_price: 11.28, name: 'BCD Item')
          item4 = create(:item, unit_price: 20, name: 'ABC Item')
          
          get '/api/v1/items/find_all?min_price=25'
          
          items = JSON.parse(response.body, symbolize_names: true)
          
          expect(response).to_not have_http_status(404)
        end

        it 'should return an error if min price less than 0' do 
          item1 = create(:item, unit_price: 3.25, name: 'DEF Item')
          item2 = create(:item, unit_price: 8.25, name: 'CDE Item')
          item3 = create(:item, unit_price: 11.28, name: 'BCD Item')
          item4 = create(:item, unit_price: 20, name: 'ABC Item')
  
          get '/api/v1/items/find_all?min_price=-2'
  
          items = JSON.parse(response.body, symbolize_names: true)
  
          expect(response).to have_http_status(400)
        end

        it 'should return an error if min price param is empty' do 
          item1 = create(:item, unit_price: 3.25, name: 'DEF Item')
          item2 = create(:item, unit_price: 8.25, name: 'CDE Item')
          item3 = create(:item, unit_price: 11.28, name: 'BCD Item')
          item4 = create(:item, unit_price: 20, name: 'ABC Item')

          get '/api/v1/items/find_all?min_price='

          items = JSON.parse(response.body, symbolize_names: true)

          expect(response).to have_http_status(400)
        end
      end
      
      context 'max_price' do
        it 'should return an array of objects' do
          item1 = create(:item, unit_price: 3.25, name: 'DEF Item')
          item2 = create(:item, unit_price: 8.25, name: 'CDE Item')
          item3 = create(:item, unit_price: 11.28, name: 'BCD Item')
          item4 = create(:item, unit_price: 20, name: 'ABC Item')

          get '/api/v1/items/find_all?max_price=10'

          expect(response).to be_successful

          items = JSON.parse(response.body, symbolize_names: true)

          expect(items[:data].count).to eq(2)

          expect(items[:data][0][:attributes][:unit_price]).to eq(8.25)
          expect(items[:data][1][:attributes][:unit_price]).to eq(3.25)
        end

        it 'should not return a 404 if no objects are found' do
          item1 = create(:item, unit_price: 3.25, name: 'DEF Item')
          item2 = create(:item, unit_price: 8.25, name: 'CDE Item')
          item3 = create(:item, unit_price: 11.28, name: 'BCD Item')
          item4 = create(:item, unit_price: 20, name: 'ABC Item')

          get '/api/v1/items/find_all?max_price=2'

          items = JSON.parse(response.body, symbolize_names: true)

          expect(response).to_not have_http_status(404)
        end

        it 'should return an error if max price less than 0' do 
          item1 = create(:item, unit_price: 3.25, name: 'DEF Item')
          item2 = create(:item, unit_price: 8.25, name: 'CDE Item')
          item3 = create(:item, unit_price: 11.28, name: 'BCD Item')
          item4 = create(:item, unit_price: 20, name: 'ABC Item')

          get '/api/v1/items/find_all?max_price=-2'

          items = JSON.parse(response.body, symbolize_names: true)

          expect(response).to have_http_status(400)
        end
        
        it 'should return an error if max price param is empty' do 
          item1 = create(:item, unit_price: 3.25, name: 'DEF Item')
          item2 = create(:item, unit_price: 8.25, name: 'CDE Item')
          item3 = create(:item, unit_price: 11.28, name: 'BCD Item')
          item4 = create(:item, unit_price: 20, name: 'ABC Item')

          get '/api/v1/items/find_all?max_price='

          items = JSON.parse(response.body, symbolize_names: true)

          expect(response).to have_http_status(400)
        end
      end

      context 'min and max_price' do
        it 'should return an array of objects' do
          item1 = create(:item, unit_price: 3.25, name: 'DEF Item')
          item2 = create(:item, unit_price: 8.25, name: 'CDE Item')
          item3 = create(:item, unit_price: 11.28, name: 'BCD Item')
          item4 = create(:item, unit_price: 20, name: 'ABC Item')

          get '/api/v1/items/find_all?min_price=2&max_price=10'

          expect(response).to be_successful

          items = JSON.parse(response.body, symbolize_names: true)

          expect(items[:data].count).to eq(2)

          expect(items[:data][0][:attributes][:unit_price]).to eq(8.25)
          expect(items[:data][1][:attributes][:unit_price]).to eq(3.25)
        end

        it 'should not return a 404 if no objects are found' do
          item1 = create(:item, unit_price: 3.25, name: 'DEF Item')
          item2 = create(:item, unit_price: 8.25, name: 'CDE Item')
          item3 = create(:item, unit_price: 11.28, name: 'BCD Item')
          item4 = create(:item, unit_price: 20, name: 'ABC Item')

          get '/api/v1/items/find_all?min_price=1&max_price=2'

          items = JSON.parse(response.body, symbolize_names: true)

          expect(response).to_not have_http_status(404)
        end

        it 'will return an error if min price greater than max price' do 
          item1 = create(:item, unit_price: 3.25, name: 'DEF Item')
          item2 = create(:item, unit_price: 8.25, name: 'CDE Item')
          item3 = create(:item, unit_price: 11.28, name: 'BCD Item')
          item4 = create(:item, unit_price: 20, name: 'ABC Item')

          get '/api/v1/items/find_all?min_price=5&max_price=2'

          items = JSON.parse(response.body, symbolize_names: true)

          expect(response).to have_http_status(400)
        end
      end
    end

    context 'name and price' do
      it 'should return an error if max_price and name parameters are used together' do
          create(:item, unit_price: 3.25)
          create(:item, unit_price: 8.25)
          create(:item, unit_price: 11.28)
          create(:item, unit_price: 2, name: "Schitt's Creek")

          get '/api/v1/items/find_all?name=creek&max_price=3'

          expect(response).to have_http_status(400)
        end

        it 'should return an error if min_price and name parameters are used together' do
          create(:item, unit_price: 3.25)
          create(:item, unit_price: 8.25)
          create(:item, unit_price: 11.28)
          create(:item, unit_price: 2, name: "Schitt's Creek")

          get '/api/v1/items/find_all?name=creek&min_price=3'

          expect(response).to have_http_status(400)
        end
    end
  end
end
