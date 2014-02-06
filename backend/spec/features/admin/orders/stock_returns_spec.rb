require 'spec_helper'

describe 'StockReturn' do

  stub_authorization!

  context 'creating a stock return' do

    let(:order) { create(:shipped_order) }

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

end