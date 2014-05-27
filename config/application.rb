require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MemoStack
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    # TimeZone
    config.time_zone = 'Tokyo'

    config.active_record.default_timezone =
      case Rails.env
      when "development"
        :utc # SQLite3
      when "test"
        :utc # SQLite3
      when "production"
        :local # MySQL
      end

    # -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    # RSpec
    config.generators do |g|
      g.test_framework = "rspec"
      g.controller_specs = false
      g.helper_specs = false
      g.view_specs = false
      # g.integration_specs = true
    end

    # -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    config.action_view.field_error_proc = ->(html_tag, instance) {
      %Q(<span class="field-with-errors">#{html_tag}</span>).html_safe
    }

    # -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    # grape
    config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]

  end
end
