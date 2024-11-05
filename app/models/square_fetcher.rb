class SquareFetcher
  def initialize(location_id)
    @location_id = location_id
  end

  def find_item(sku)
    result = client.catalog.search_catalog_items(body: { text_filter: sku })
    if result.success?
      parse_item(result.data.items.first)
    else
      nil
    end
  end

  def fetch_inventory_counts(item_ids)
    result = client.inventory.batch_retrieve_inventory_counts(
      body: {
        catalog_object_ids: item_ids,
        location_ids: [@location_id],
      },
    )
    if result.success?
      parse_inventory(result.data.counts)
    else
      {}
    end
  end

  def parse_item(item)
    variation = item[:item_data][:variations][0]
    {
      id: item[:id],
      name: item[:item_data][:name],
      description: item[:item_data][:description],
      sku: variation[:item_variation_data][:sku],
      variation_id: variation[:id],
      vendor: variation[:item_variation_data][:name],
      price: variation[:item_variation_data][:price_money][:amount],
    }
  end

  def parse_inventory(counts)
    counts.collect do |count|
      next unless count[:state] == "IN_STOCK"
      [count[:catalog_object_id], count[:quantity]]
    end.compact.to_h
  end

  def client
    @client ||= Square::Client.new(
      bearer_auth_credentials: Square::BearerAuthCredentials.new(
        access_token: ENV["SQUARE_ACCESS_TOKEN"],
      ),
      environment: "production",
    )
  end
end
