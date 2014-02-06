require 'spec_helper'

describe 'StockReturn' do

  stub_authorization!
    
  let(:order) { create(:shipped_order) }

  context 'creating a stock return' do

    before do
      visit spree.edit_admin_order_path(order)
      click_link 'Stock Returns'
    end

    it 'can create one successfully' do
      click_link 'New Stock Return'
      click_button 'Create'
      expect(page).to have_content('Stock Return has been successfully created')
    end

  end

  context 'with a stock return' do

    let!(:stock_return) { create(:stock_return, :order => order)}

    before do
      visit spree.admin_order_stock_returns_path(order)
    end

    it 'can create a refund' do
      within '#listing_stock_returns' do
        click_link stock_return.id
      end

      within '#refunds' do
        select order.variants.first.sku, :from => 'SKU'
        fill_in 'Quantity', :with => 1
        click_button 'Add'
      end
    end

  end

end