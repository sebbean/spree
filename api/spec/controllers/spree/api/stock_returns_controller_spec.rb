require 'spec_helper'

describe Spree::Api::StockReturnsController do
  render_views

  before do
    stub_authentication!
  end

  let(:order) { create(:shipped_order) }

  context "as a user" do
    it "cannot create a stock return" do
      api_post :create, order_id: order.number
      response.status.should == 401
    end
  end

  context "as an admin" do
    sign_in_as_admin!

    it "can create a stock return" do
      api_post :create, order_id: order.number
      response.should be_success
    end
  end
end