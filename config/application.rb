require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SampleApp
  class Application < Rails::Application
    config.assets.paths << ::Rails.root.join('app', 'models').to_s
    # include the authenticity token in remote forms
    config.action_view.embed_authenticity_token_in_remote_forms = true
  end
end
