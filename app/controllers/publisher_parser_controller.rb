class PublisherParserController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def upload
    csv = params.require(:publisher_csv).read
    publisher_type = params.require(:publisher_type)
    parser = PublisherParser.new(csv, publisher_type)
    if parser.parse
      send_data parser.to_csv, type: "text/csv", filename: "#{publisher_type}_parsed-#{Time.now.to_i}.csv"
    else
      flash[:error] = "There was a problem parsing the file. Please check the format and try again."
    end
  end
end
