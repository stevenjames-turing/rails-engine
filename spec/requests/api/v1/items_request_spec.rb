require 'rails_helper'

describe "Items API" do
  it 'sends a list of items' do
    create_list(:item, 3)

    get '/api/v1/items'

    expect(response).to be_successful

    items = JSON.parse(response.body, symbolize_names: true)

    expect(items.count).to eq(3)

    items.each do |item|  
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

  it 'can get one item by its ID' do 
    id = create(:item).id 
    id2 = create(:item).id 

    get "/api/v1/items/#{id}"

    item = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    
    expect(item).to have_key(:id)
    expect(item[:id]).to eq(id)
    expect(item[:id]).to_not eq(id2)
    
    expect(item).to have_key(:name)
    expect(item[:name]).to be_a String 
  end

  it 'can create a new item' do 
    merchant = create(:merchant)
    item_params = ({
                    merchant_id: merchant.id, 
                    name: 'Ethiopia Limu Gera', 
                    description: 'Single origin coffee', 
                    unit_price: 12.99, 
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

  it 'can update an existing item' do 
    id = create(:item).id
    previous_name = Item.last.name 
    item_params = { name: "Ethiopia Limu Gera" }
    headers = {"CONTENT_TYPE" => "application/json"}

    # We include this header to make sure that these params are passed as JSON rather than as plain text
    patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: item_params})
    item = Item.find_by(id: id)

    expect(response).to be_successful
    expect(item.name).to_not eq(previous_name)
    expect(item.name).to eq("Ethiopia Limu Gera")
  end

  it 'can destroy a item' do 
    item = create(:item)

    expect(Item.count).to eq(1) 

    delete "/api/v1/items/#{item.id}"

    expect(response).to be_successful
    expect(Item.count).to eq(0)
    expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'can get the merchant info for an item with item ID' do 
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
end 