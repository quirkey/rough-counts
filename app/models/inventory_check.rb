class InventoryCheck < ApplicationRecord
  belongs_to :user

  def skus=(value)
    super(value.split("\n").map(&:strip).reject(&:empty?).join("\n"))
  end
end
