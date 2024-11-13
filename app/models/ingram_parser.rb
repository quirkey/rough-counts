require "csv"

class IngramParser
  SQUARE_TEMPLATE = {
    "Reference Handle" => nil,
    "Token" => nil,
    "Item Name" => nil,
    "Variation Name" => "Ingram",
    "Unit and Precision" => nil,
    "SKU" => nil,
    "Description" => nil,
    "Reporting Category" => "Books",
    "Additional Categories" => nil,
    "SEO Title" => nil,
    "SEO Description" => nil,
    "Permalink" => nil,
    "GTIN" => nil,
    "Square Online Item Visibility" => "unavailable",
    "Item Type" => "physical",
    "Weight (lb)" => nil,
    "Shipping Enabled" => "N",
    "Self-serve Ordering Enabled" => "N",
    "Delivery Enabled" => "N",
    "Pickup Enabled" => "N",
    "Price" => nil,
    "Online Sale Price" => nil,
    "Archived" => "N",
    "Sellable" => "Y",
    "Stockable" => "Y",
    "Skip Detail Screen in POS" => "N",
    "Default Unit Cost" => nil,
    "Default Vendor Name" => "Ingram",
    "Default Vendor Code" => "ING",
    "Current Quantity Rough Draft Bar & Books" => nil,
    "New Quantity Rough Draft Bar & Books" => nil,
    "Stock Alert Enabled Rough Draft Bar & Books" => "N",
    "Stock Alert Count Rough Draft Bar & Books" => nil,
    "Tax - Clothing Tax (4%)" => "N",
    "Tax - NY/Ulster Sales Tax (8%)" => "Y",
    "Tax - Sales Tax Included (8%)" => "N",
  }

  attr_reader :file_data

  def initialize(file_data)
    @file_data = file_data
  end

  def parse
    items = []
    csv = CSV.parse(file_data, headers: true)
    csv.each do |row|
      new_book = row["Notes"] =~ /NEW/
      req_book = row["Notes"] =~ /REQ/
      next unless new_book || req_book

      item = SQUARE_TEMPLATE.dup
      title = row["Product Name"]
      title = "REQ - #{title}" if req_book
      item["Item Name"] = "#{title} - #{row["Contributor"]} - #{row["Format"]} - #{row["Supplier"]}"
      item["SKU"] = row["EAN"]
      item["Description"] = "#{row["Pub Date"]} - #{row["BISAC Category"]}"
      item["Reporting Category"] = "Book Requests" if req_book
      item["Price"] = row["Retail Price"]
      items << item
    end
    @items = items
  end

  def to_csv
    parse if @items.nil?
    CSV.generate do |csv|
      csv << SQUARE_TEMPLATE.keys
      @items.each do |item|
        csv << item.values
      end
    end
  end
end
