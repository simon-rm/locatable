require "rails/railtie"
require "locatable/migration_helpers"

module MyGem
  class Railtie < Rails::Railtie
    initializer "locatable.migration_helpers" do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Migration.include Locatable::MigrationHelpers
      end
    end
  end
end