require "ostruct"

class InventoryCheck < ApplicationRecord
  belongs_to :user

  def skus=(value)
    super(value.split("\n").map(&:strip).reject(&:empty?).uniq.join("\n"))
  end

  def skus_array
    skus.split("\n")
  end

  def inventory_items
    data.collect { |item| OpenStruct.new(item) }
  end

  def fetch_data!
    return [] if skus.blank?
    items = skus_array.collect { |sku| fetcher.find_item(sku) }.compact
    item_ids = items.collect { |item| item[:variation_id] || item[:id] }
    inventory_counts = fetcher.fetch_inventory_counts(item_ids)
    items.each do |item|
      item[:quantity] = inventory_counts[item[:variation_id] || item[:id]] || 0
    end
    self.data = items
    save!
  end

  private

  def fetcher
    @fetcher ||= SquareFetcher.new(user.location_id)
  end
end
