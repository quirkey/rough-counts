# frozen_string_literal: true

require "csv"

class Sheet < ApplicationRecord
  DEFAULT_WORKSHEET_TITLE = "BY CUSTOMER (EDIT HERE)"
  TIMES_NEEDED = ["LEVAIN", "COUNTRY", "SEMOLINA", "BAGUETTE", "FOCACCIA", "DAILY MIX-IN"]
  validates :key, :name, presence: true

  def self.url_to_sheet_key(url)
    url.include?("/d/") ? url.match(/\/spreadsheets\/d\/(.*)\//)[1] : url
  end

  def self.from_url_or_key(url)
    sheet = find_or_initialize_by(key: url_to_sheet_key(url))
    sheet.worksheet_title = DEFAULT_WORKSHEET_TITLE
    sheet.fetch!
    sheet
  end

  def fetch!
    sheet = fetcher.fetch
    raise "No worksheet found with title '#{worksheet_title}'" unless sheet

    self.name = sheet.spreadsheet.title
    self.last_fetched_at = Time.now
    self.last_modified_at = sheet.updated
    self.data = sheet.export_as_string
    @customers = nil
    save!
  end

  def date
    Date.strptime(name, "%m-%d")
  rescue Date::Error
    created_at.to_date
  end

  def fetcher
    @fetcher ||= SheetFetcher.new(key, worksheet_title)
  end

  def customers
    @parsed_data ||= parse_data
    @parsed_data[:customers]
  end

  def times
    @parsed_data ||= parse_data
    @parsed_data[:times]
  end

  def has_times?
    times.present? && times.values.any?(&:present?)
  end

  def item_count
    customers.sum { |customer| customer[:orders].values.sum { |order| order[:items].values.sum } }
  end

  def filtered_customers_and_weekdays(customer_ids, weekday_ids)
    filtered_customers = customers
    customer_select = customer_ids.collect(&:to_i).compact
    filtered_customers = filtered_customers.find_all { |customer| customer_select.include?(customer[:account_number]) } if customer_select.present? && !customer_select.include?(0)
    filtered_customers.each do |customer|
      orders = customer[:orders]
      orders = orders.select { |_weekday, order| order[:items].values.sum.positive? }
      orders = orders.select { |weekday, _order| weekday_ids.include?(weekday) } if weekday_ids.present?
      customer[:orders] = orders
    end
    filtered_customers
  end

  def filtered_times_by_weekdays(weekday_ids)
    times.select { |weekday, _time| weekday_ids.include?(weekday) }
  end

  private

  def data_to_csv
    file_lines = data.split("\r\n")
    # remove the first line
    file_contents = file_lines[1..].join("\r\n")
    CSV.parse(file_contents, headers: true)
  end

  def parse_data
    current_customer = {}
    customers = []
    times = {}
    parsed = data_to_csv
    parsed.each do |row|
      if row["ACCT #"] =~ /^\d/
        customers << current_customer if current_customer.present?
        current_customer = {
          account_number: row["ACCT #"].to_i,
          name: row["ACCT NAME"],
          orders: {},
        }
      elsif row["ACCT NAME"] =~ /\w/
        order = { items: {}, notes: nil }
        times[row["ACCT NAME"]] ||= {}
        row.each do |header, value|
          next unless header.present?
          header = header.chomp
          if header == "NOTES"
            order[:notes] = value if value =~ /\w/
          elsif header == "TIME NEEDED"
            next
          elsif value =~ /^\d/ && value.to_i.positive?
            if row["TIME NEEDED"] =~ /^\d/ && TIMES_NEEDED.include?(header)
              times[row["ACCT NAME"]][row["TIME NEEDED"]] ||= {}
              times[row["ACCT NAME"]][row["TIME NEEDED"]][header] ||= 0
              times[row["ACCT NAME"]][row["TIME NEEDED"]][header] += value.to_i
            end
            order[:items][header] = value.to_i
          end
        end
        current_customer[:orders][row["ACCT NAME"]] = order
      end
      current_customer[:notes] = row["NOTES"] if row["NOTES"] =~ /\w/
    end
    customers << current_customer
    { customers: customers, times: times }
  end
end
