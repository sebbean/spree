require 'spec_helper'

describe "Orders", js: true do
  stub_authorization!
  
  let(:order) { create(:completed_order_with_totals, line_items_count: 1) }
  let(:first_product) { order.line_items.first.product }

  def go_to_delivery_tab
    visit spree.edit_admin_order_path(order)
    find("#states #delivery_state").click()
  end

  before { go_to_delivery_tab }

  it "can add tracking information" do
    within(".show-tracking") do
      click_icon :edit
    end
    fill_in "tracking", :with => "FOOBAR"
    click_icon :ok

    page.should_not have_css("input[name=tracking]")
    page.should have_content("Tracking: FOOBAR")
  end

  context "changing the shipping method" do
    before do
      create(:shipping_method, name: 'Some Other Method')
      order.refresh_shipment_rates
      go_to_delivery_tab
    end

    it "changes the shipping method" do
      within("table.index tr.show-method") do
        click_icon :edit
      end

      select2 "Some Other Method", :from => "Shipping Method"
      click_icon :ok

      page.should_not have_css('#selected_shipping_rate_id')
      page.should have_content("Some Other Method")
    end
  end


  it "can delete an item from the shipment" do
    page.should have_content(first_product.name)

    within_row(1) do
      accept_alert do
        click_icon :trash
      end
    end

    # Click "ok" on confirmation dialog
    page.should_not have_content(first_product.name)
    within("#order_total") do
      page.should have_content("$0.00")
    end
  end


  # Regression test for #3862
  it "can cancel deleting a line item" do
    page.should have_content(first_product.name)

    within_row(1) do
      # Click "cancel" on confirmation dialog
      dismiss_alert do
        click_icon :trash
      end
    end

    page.should have_content(first_product.name)
  end

  context "with special_instructions present" do
    before do
      order.update_column(:special_instructions, "Very special instructions here")
      go_to_delivery_tab
    end

    it "will show the special_instructions" do
      expect(page).to have_content("Very special instructions here")
    end
  end
end