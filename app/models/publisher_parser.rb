require "csv"

class PublisherParser
  PUBLISHER_TYPES = [
    ["Ingram", "ingram"],
    ["Penguin", "PRH"],
    ["Macmillan", "MPS"],
    ["Norton", "WWN"],
    ["Simon", "SS"],
    ["IPS", "IPS"],
    ["Hachette", "HBG"],
  ]
  SQUARE_TEMPLATE = {
    "Reference Handle" => nil,
    "Token" => nil,
    "Item Name" => nil,
    "Variation Name" => "Publisher",
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
    "Default Vendor Name" => "Publisher",
    "Default Vendor Code" => "ING",
    "Current Quantity Rough Draft Bar & Books" => nil,
    "New Quantity Rough Draft Bar & Books" => nil,
    "Stock Alert Enabled Rough Draft Bar & Books" => "N",
    "Stock Alert Count Rough Draft Bar & Books" => nil,
    "Tax - Clothing Tax (4%)" => "N",
    "Tax - NY/Ulster Sales Tax (8%)" => "Y",
    "Tax - Sales Tax Included (8%)" => "N",
  }

  attr_reader :file_data, :publisher_type

  def initialize(file_data, publisher_type)
    @file_data = file_data
    @publisher_type = publisher_type
  end

  def parse_ingram
    @items = parse_rows do |item, row|
      new_book = row["Notes"] =~ /^NEW/
      req_book = row["Notes"] =~ /^REQ/
      next unless new_book || req_book

      title = row["Product Name"]
      title = "REQ - #{title}" if req_book
      item["Item Name"] = "#{title} - #{row["Contributor"]} - #{row["Format"]} - #{row["Supplier"]}"
      item["Variation Name"] = row["Supplier"]
      item["SKU"] = row["EAN"]
      item["Description"] = "#{row["Pub Date"]} - #{row["BISAC Category"]}"
      item["Reporting Category"] = "Book Requests" if req_book
      item["Price"] = row["US SRP"]
      item
    end
  end

  def parse_edws
    @items = parse_rows do |item, row|
      title = row["Title:Subtitle"]
      publisher_name = PUBLISHER_TYPES.find { |_, code| code == publisher_type }&.first
      item["Item Name"] = "#{title} - #{row["Author"]} - #{row["Format Description"]} - #{row["Publisher Name"]}"
      item["Variation Name"] = publisher_name
      item["Default Vendor Name"] = publisher_name
      item["Default Vendor Code"] = publisher_type
      item["SKU"] = row["EAN"]
      item["Description"] = "#{row["PubDate"]} - #{row["BISAC Category Description"]}"
      item["Price"] = row["List Price"]
      item
    end
  end

  def parse
    if publisher_type == "ingram"
      parse_ingram
    else
      parse_edws
    end
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

  private

  def parse_rows
    items = []

    csv = CSV.parse(file_data, headers: true)
    csv.each do |row|
      item = SQUARE_TEMPLATE.dup
      i = yield(item, row)
      items << i if i
    end
    items
  end
end
