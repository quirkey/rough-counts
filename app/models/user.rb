# frozen_string_literal: true

class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:square]

  def self.from_omniauth(access_token)
    info = access_token.info
    user = User.find_or_initialize_by(uid: access_token.uid, provider: access_token.provider)
    user.attributes = {
      name: info["name"],
      provider: access_token.provider,
      uid: access_token.uid,
      access_token: access_token.credentials.token,
      refresh_token: access_token.credentials.refresh_token,
      refresh_token_expires_at: Time.at(access_token.credentials.expires_at),
    }
    user.save
    user
  end

  def display_name
    name.presence || "Logged In User"
  end
end
