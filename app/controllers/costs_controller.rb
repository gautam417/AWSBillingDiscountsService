require 'clickhouse-activerecord'

class CostsController < ApplicationController
    before_action :authenticate_request!, except: :index
    before_action :log_request

    def index
    end 
    
    def undiscounted
        service = params[:service]
        begin
            total_cost = LineItem.total_unblended_cost(service)
            render json: { service: service, undiscounted_cost: total_cost }
        rescue => e
            render json: { error: "Failed to retrieve undiscounted cost: #{e.message}" }, status: :unprocessable_entity
        end
    end
    
    def discounted
        service = params[:service]
        begin
          total_cost = LineItem.total_discounted_cost(service)
          render json: { service: service, discounted_cost: total_cost }
        rescue => e
          render json: { error: "Failed to retrieve discounted cost: #{e.message}" }, status: :unprocessable_entity
        end
    end

    def blended_rate
        begin
            blended_rate = LineItem.blended_discount_rate
            render json: { blended_rate: blended_rate }
        rescue => e
            render json: { error: "Failed to retrieve blended rate: #{e.message}" }, status: :unprocessable_entity
        end
    end

    private 

    def log_request
        Rails.logger.info "Processing #{action_name} action for #{controller_name} controller"
    end 
end 