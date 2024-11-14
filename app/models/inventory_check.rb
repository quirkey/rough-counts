require "ostruct"
require "csv"

class InventoryCheck < ApplicationRecord
  belongs_to :user
  validates :skus, presence: true

  def skus=(value)
    super(value.split("\n").map(&:strip).reject(&:empty?).uniq.join("\n"))
  end

  def skus_array
    skus.split("\n")
  end

  def to_csv
    CSV.generate("") do |csv|
      csv << data.first.keys
      data.each do |item|
        csv << item.values
      end
      csv
    end
  end

  def inventory_items
    data.collect { |item| OpenStruct.new(item) }
  end

  def fetch_data!
    return [] if skus.blank?
    items = skus_array.collect { |sku| fetcher.find_item(sku) }.compact
    item_ids = items.collect { |item| item[:variation_id] || item[:id] }
    logger.debug "Item IDs: #{item_ids.length}"
    inventory_counts = fetcher.fetch_inventory_counts(item_ids)
    logger.debug "Counts: #{inventory_counts.length}"
    items.each do |item|
      item[:quantity] = inventory_counts[item[:variation_id] || item[:id]] || 0
    end
    self.data = items
    save!
  end

  private

  def fetcher
    @fetcher ||= SquareFetcher.new(ENV["LOCATION_ID"])
  end
end
