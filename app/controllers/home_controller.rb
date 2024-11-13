# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    if user_signed_in?
      redirect_to inventory_checks_path
    else
      redirect_to controller: "sessions", action: "new"
    end
  end
end
