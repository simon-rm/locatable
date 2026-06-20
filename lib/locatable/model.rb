require "locatable/scopes"
module Locatable::Model
  extend ActiveSupport::Concern

  class_methods do
    def locatable
      include Locatable::Scopes
    end
  end
end