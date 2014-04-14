# coding: utf-8
require 'spec_helper'

describe "Order Details", js: true do
  let(:order) { create(:completed_order_with_totals) }

  context 'with only read permissions' do
    before do
      user = mock_model("Spree::LegacyUser")
      Spree::Api::BaseController.any_instance.stub(:try_spree_current_user).and_return(user)
      visit spree.edit_admin_order_path(order)
    end

    custom_authorization! do |user|
      can [:admin, :index, :show, :edit], Spree::Order
    end

    it "should not display forbidden links" do
      page.should_not have_button('cancel')
      page.should_not have_button('Resend')

      # Order Tabs
      page.should_not have_link('Order Details')
      page.should_not have_link('Customer Details')
      page.should_not have_link('Adjustments')
      page.should_not have_link('Payments')
      page.should_not have_link('Return Authorizations')

      # Cart actions
      find("#states #cart_state").click()
      binding.pry
      page.should_not have_css('#add-line-item')

      # Shipment item actions
      find("#states #delivery_state").click()
      binding.pry
      page.should_not have_css('.delete-item')
      page.should_not have_css('.split-item')
      page.should_not have_css('.edit-item')
      page.should_not have_css('.edit-tracking')
    end
  end

  context 'as Fakedispatch' do
    custom_authorization! do |user|
      # allow dispatch to :admin, :index, and :edit on Spree::Order
      can [:admin, :edit, :index, :read], Spree::Order
      # allow dispatch to :index, :show, :create and :update shipments on the admin
      can [:admin, :manage, :read, :ship], Spree::Shipment
    end

    before do
      Spree::Api::BaseController.any_instance.stub :try_spree_current_user => Spree.user_class.new
    end

    it 'should not display order tabs or edit buttons without ability' do
      visit spree.edit_admin_order_path(order)

      # Order Form
      page.should_not have_css('.edit-item')
      # Order Tabs
      page.should_not have_link('Order Details')
      page.should_not have_link('Customer Details')
      page.should_not have_link('Adjustments')
      page.should_not have_link('Payments')
      page.should_not have_link('Return Authorizations')
    end

    it "can add tracking information" do
      visit spree.edit_admin_order_path(order)
      within("table.index tr:nth-child(5)") do
        click_icon :edit
      end
      fill_in "tracking", :with => "FOOBAR"
      click_icon :ok

      page.should_not have_css("input[name=tracking]")
      page.should have_content("Tracking: FOOBAR")
    end

    it "can change the shipping method" do
      order = create(:completed_order_with_totals)
      visit spree.edit_admin_order_path(order)
      within("table.index tr.show-method") do
        click_icon :edit
      end
      select2 "Default", :from => "Shipping Method"
      click_icon :ok

      page.should_not have_css('#selected_shipping_rate_id')
      page.should have_content("Default")
    end

    it 'can ship' do
      order = create(:order_ready_to_ship)
      order.refresh_shipment_rates
      visit spree.edit_admin_order_path(order)
      click_icon 'arrow-right'
      wait_for_ajax
      within '.shipment-state' do
        page.should have_content('SHIPPED')
      end
    end
  end
end
