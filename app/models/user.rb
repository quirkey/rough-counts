# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  def self.from_omniauth(access_token)
    info = access_token.info
    user = User.find_or_initialize_by(email: info["email"])
    user.attributes = {
      name: info["name"],
      email: info["email"],
      provider: access_token.provider,
      password: Devise.friendly_token[0, 20],
      uid: access_token.uid,
      access_token: access_token.credentials.token,
      refresh_token: access_token.credentials.refresh_token,
      refresh_token_expires_at: Time.at(access_token.credentials.expires_at)
    }
    user.save
    user
  end

  def display_name
    name.presence || email
  end
end
