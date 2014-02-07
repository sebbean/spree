require 'spec_helper'

describe Spree::Refund do

  let(:order) { create(:shipped_order) }
  let(:stock_return) { create(:stock_return, :order => order) }
  let(:variant) { order.variants.first }

  def assert_refund_items(refund, quantity, variant, currency)
    expect(refund.items.count).to eq(quantity)
    expect(refund.items.first.variant).to eq(variant)
    expect(refund.items.first.currency).to eq(order.currency)
  end

  it 'creates refund items' do
    refund = stock_return.refunds.create(:variant_id => variant.id, :quantity => 1)
    assert_refund_items(refund, 1, variant, order.currency)
  end

  it 'can refund three items' do
    refund = stock_return.refunds.create(:variant_id => variant.id, :quantity => 3)
    assert_refund_items(refund, 3, variant, order.currency)
  end

  it 'creates refund items with a string quantity' do
    refund = stock_return.refunds.create(:variant_id => variant.id, :quantity => '1')
    assert_refund_items(refund, 1, variant, order.currency)
  end

  it 'sets the total price' do
    refund = stock_return.refunds.create(:variant_id => variant.id, :quantity => 1)
    expect(refund.total_price).to eq(order.find_line_item_by_variant(variant).price)
  end

end