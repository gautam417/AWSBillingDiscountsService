class AuthenticationController < ApplicationController
    SECRET_KEY = Rails.application.secret_key_base

    def authenticate
        username = params[:username]
        password = params[:password]

        if username == 'admin' && password == 'secret'
            payload = { user: username, exp: 24.hours.from_now.to_i } 
            token = JWT.encode(payload, SECRET_KEY)

            Rails.logger.info "User '#{username}' successfully authenticated"
            render json: { token: token }
        else 
            Rails.logger.warn "Failed authentication attempt with username '#{username}'"
            render json: { error: 'Invalid username or password' }, status: :unauthorized
        end 
    end 
end 