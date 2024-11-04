# frozen_string_literal: true

class SheetFetcher
  def initialize(key, worksheet_title)
    @key = key
    @worksheet_title = worksheet_title
  end

  def session
    @session ||= GoogleDrive::Session.from_service_account_key("#{Rails.root}/config/google-creds.json")
  end

  def fetch
    session.spreadsheet_by_key(@key).worksheet_by_title(@worksheet_title)
  end
end
