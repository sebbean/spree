module Spree
  module Api
    module ControllerSetup
      def self.included(klass)
        klass.class_eval do
          include AbstractController::Rendering
          include AbstractController::ViewPaths
          include AbstractController::Callbacks
          include AbstractController::Helpers

          include ActiveSupport::Rescuable

          include ActionController::Rendering
          include ActionController::ImplicitRender
          include ActionController::Rescue
          include ActionController::MimeResponds

          include CanCan::ControllerAdditions
          include SslRequirement
          respond_to :json
        end
      end
    end
  end
end
