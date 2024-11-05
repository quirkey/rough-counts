class InventoryChecksController < ApplicationController
  before_action :authenticate_user!

  def index
    @inventory_check = InventoryCheck.new
  end

  def create
    @inventory_check = current_user.inventory_checks.build(inventory_check_params)
    if @inventory_check.save
      redirect_to inventory_check_path(@inventory_check)
    else
      render :index
    end
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
