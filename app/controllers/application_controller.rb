class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session

    SECRET_KEY= Rails.application.secret_key_base

    def authenticate_request!
        header = request.headers['Authorization']
        
        if header.present?
            token = header.split(' ').last 
            begin 
                decoded = decode_token(token)
                @current_user = decoded[:user] if decoded
                Rails.logger.info "User authenticated: #{@current_user}" if @current_user
            rescue JWT::DecodeError => e
                Rails.logger.error "JWT decode error: #{e.message}"
                render json: { errors: 'Unauthorized request' }, status: :unauthorized
                return
            end
        else
            Rails.logger.warn "Unauthorized request: Authorization header missing"
            render json: { errors: 'Unauthorized request' }, status: :unauthorized
            return
        end
        
        unless @current_user
            Rails.logger.warn "Unauthorized request: Invalid token"
            render json: { errors: 'Unauthorized request' }, status: :unauthorized
            return
        end
    end

    private 

    def decode_token(token)
        decoded = JWT.decode(token, SECRET_KEY)[0]
        HashWithIndifferentAccess.new(decoded)
    rescue JWT::DecodeError => e
        Rails.logger.error "JWT decode error while decoding token: #{e.message}"
        nil
    end 
end
