class LineItem < ActiveRecord::Base
  self.table_name = 'line_items'

  scope :usage_items, -> { where(line_item_line_item_type: 'Usage') }
  scope :by_service, ->(service) { where(product_servicecode: service) }

  DISCOUNTS = {
    'AmazonS3' => 0.12,
    'AmazonEC2' => 0.50,
    'AWSDataTransfer' => 0.30,
    'AWSGlue' => 0.05,
    'AmazonGuardDuty' => 0.75
  }

  def self.total_unblended_cost(service)
    by_service(service).usage_items.sum(:line_item_unblended_cost).to_f.round(2)
  end

  def self.total_discounted_cost(service)
    discount = DISCOUNTS[service] || 0
    by_service(service).usage_items.sum("line_item_unblended_cost * (1 - #{discount})").round(2)
  end

  def self.blended_discount_rate
    total_unblended = 0
    total_discounted = 0

    DISCOUNTS.each do |service, discount|
      unblended_cost = total_unblended_cost(service)
      discounted_cost = total_discounted_cost(service)

      total_unblended += unblended_cost
      total_discounted += discounted_cost
    end

    Rails.logger.info "Total Unblended Cost: #{total_unblended}"
    Rails.logger.info "Total Discounted Cost: #{total_discounted}"

    if total_unblended > 0
      blended_rate = (total_discounted / total_unblended * 100).round(2)
    else
      blended_rate = 0.0
    end
  end
end
