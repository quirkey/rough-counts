OmniAuth.config.full_host = Rails.env.production? ? 'https://rough-counts.fly.dev' : 'https://rough-counts.loca.lt'
OmniAuth.config.logger = Rails.logger if Rails.env.development?
