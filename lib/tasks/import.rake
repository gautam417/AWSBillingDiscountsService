namespace :import do
    desc "Import AWS billing data from Parquet file"
    task billing_data: :environment do
        require 'arrow'
        require 'parquet'
        require 'clickhouse-activerecord'
        
        Rails.logger.info "Starting import task"
        file_path = Rails.root.join('aws_billing', 'Oct2018-WorkshopCUR-00001.snappy.parquet').to_s
        
        Rails.logger.info "Opening Parquet file: #{file_path}"
        
        unless File.exist?(file_path)
            Rails.logger.error "Parquet file not found at #{file_path}"
            return
        end
          
        table = Arrow::Table.load(file_path, format: :parquet)
        Rails.logger.info "Parquet file opened successfully"

        line_items = []
        table.each_record do |record|
            if record['line_item_line_item_type'] == 'Usage'
                line_items << {
                    line_item_unblended_cost: record['line_item_unblended_cost'].to_f,
                    product_servicecode: record['product_servicecode'] || '', # Handle nil product_servicecode
                    line_item_line_item_type: record['line_item_line_item_type']
                }
            end
        end

        Rails.logger.info "Prepared #{line_items.size} line items for import"

        ActiveRecord::Base.establish_connection(
            adapter: 'clickhouse',
            database: 'aws_billing',
            host: 'localhost',
            port: 8123
        )

        class LineItem < ActiveRecord::Base 
            self.table_name = 'line_items'
        end 

        if line_items.any?
            begin
                line_items.each do |item|
                    LineItem.create!(item)
                end
                Rails.logger.info "Imported line items into the database"
            rescue => e
                Rails.logger.info "Import failed: #{e.message}"
            end 
        else 
            Rails.logger.info "No line items to import"
        end
    end
end
