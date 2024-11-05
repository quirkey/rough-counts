class InventoryChecksController < ApplicationController
  before_action :authenticate_user!

  def index
    @inventory_check = InventoryCheck.new
    @inventory_checks = InventoryCheck.order(created_at: :desc).limit(15)
  end

  def create
    @inventory_check = current_user.inventory_checks.build(inventory_check_params)
    if @inventory_check.save
      @inventory_check.fetch_data!
      redirect_to inventory_check_path(@inventory_check)
    else
      render :index
    end
  rescue => e
    flash[:error] = "There was a problem fetching data: #{e.message}"
    redirect_to inventory_checks_path
  end

  def show
    @inventory_check = InventoryCheck.find(params[:id])
  end

  def csv
    @inventory_check = InventoryCheck.find(params[:id])
    send_data @inventory_check.to_csv, type: "text/csv", filename: "inventory_check-#{@inventory_check.created_at.to_i}.csv"
  end

  private

  def inventory_check_params
    params.require(:inventory_check).permit(:skus)
  end
end
