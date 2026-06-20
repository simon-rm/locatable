require "rails/railtie"
require "locatable/migration_helpers"
require "locatable/model"

module Locatable
  class Railtie < Rails::Railtie
    initializer "locatable.migration_helpers" do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Migration.include Locatable::MigrationHelpers
      end
    end

    initializer "locatable.active_record" do
      ActiveSupport.on_load(:active_record) do
        include Locatable::Model
      end
    end
  end
end
