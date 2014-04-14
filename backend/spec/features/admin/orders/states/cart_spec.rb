require 'spec_helper'

describe "Orders", js: true do
  stub_authorization!
  
  let(:order) { Spree::Order.create }
  let(:t_shirt) { create(:base_product, name: 'spree t-shirt', price: 20, sku: 'TSHIRT-001') }

  before do
    order.contents.add(t_shirt.master)
    visit spree.edit_admin_order_path(order)
    find("#states #cart_state").click()
  end

  it "will show the variant sku" do
    expect(page).to have_content("SKU: TSHIRT-001")
  end

  it "editing a line item's quantity" do
    page.should have_content("spree t-shirt")
    page.should have_content("$20.00")

    within_row(1) do
      click_icon :edit
      find(".line_item_quantity").set(2)
    end
    click_icon :ok

    within("#order_total") do
      page.should have_content("$40.00")
    end
  end

  context "adding a new item to the order" do
    let(:tote) { create(:product, :name => "Tote", :price => 15.00) }
    it "with stock tracking" do
      select2_search "Tote", :from => Spree.t(:name_or_sku)
      within("table.stock-levels") do
        fill_in "stock_item_quantity", :with => 1
        click_icon :plus
      end

      within("#line-items") do
        page.should have_content("Tote")
      end

      within("#order_total") do
        page.should have_content("$35.00") # $20 + $15
      end
    end

    context "variant out of stock and not backorderable" do
      before { tote.master.stock_items.first.update_column(:backorderable, false) }

      it "displays out of stock instead of add button" do
        select2_search tote.name, :from => Spree.t(:name_or_sku)
        within("table.stock-levels") do
          page.should have_content(Spree.t(:out_of_stock))
        end
      end
    end

    context "variant doesn't track inventory" do
      before do
        tote.master.update_column :track_inventory, false
        # make sure there's no stock level for any item
        tote.master.stock_items.update_all count_on_hand: 0, backorderable: false
      end

      it "adds variant to order just fine"  do
        select2_search tote.name, :from => Spree.t(:name_or_sku)

        within("table.stock-levels") do
          fill_in "stock_item_quantity", :with => 1
          click_icon :plus
        end

        within("#line-items") do
          page.should have_content(tote.name)
        end
      end
    end
  end

  it "can delete a line item" do
    page.should have_content(t_shirt.name)

    within_row(1) do
      accept_alert do
        click_icon :trash
      end
    end

    # Click "ok" on confirmation dialog
    page.should_not have_content(t_shirt.name)
    within("#order_total") do
      page.should have_content("$0.00")
    end
  end


  # Regression test for #3862
  it "can cancel deleting a line item" do
    page.should have_content(t_shirt.name)

    within_row(1) do
      # Click "cancel" on confirmation dialog
      dismiss_alert do
        click_icon :trash
      end
    end

    page.should have_content(t_shirt.name)
  end
end