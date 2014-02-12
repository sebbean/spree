require 'spec_helper'

describe Spree::Core::ControllerHelpers::Auth, :type => :controller do
  controller do
    include Spree::Core::ControllerHelpers::Auth
    before_filter :check_authorization

    def index; end
  end

  # regression tests for #4333
  context "authorization error handling" do
    let(:user)  { stub_model(Spree::LegacyUser) }

    context "User is not authorized to perform requested action" do
      let(:fallback_path) { '/' + Faker::Lorem.words.first }

      before do
        controller.stub(:check_authorization).and_raise(CanCan::AccessDenied)
        controller.stub(:fallback_login_path) { fallback_path } 
      end

      after { get :index }

      context "user is not logged in" do
        before do
          controller.stub :try_spree_current_user => nil
          controller.stub :spree_current_user     => nil
        end

        it "should redirect to the fallback login path" do
          controller.should_receive(:redirect_back_or_default).with(fallback_path)
        end
      end

      context "user is logged in" do
        before do
          controller.stub :try_spree_current_user => user
          controller.stub :spree_current_user     => user
        end

        it "should redirect to the previous (referrer) page" do
          controller.should_receive(:redirect_back_or_default)
        end
      end
    end
  end
end
