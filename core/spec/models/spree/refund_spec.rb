require 'spec_helper'

describe Spree::Refund do

  let(:order) { create(:shipped_order) }
  let(:stock_return) { create(:stock_return, :order => order) }

  it 'creates refund items' do
    variant = order.variants.first
    refund = stock_return.refunds.create(:variant_id => variant.id, :quantity => 1)
    expect(refund.items.count).to eq(1)
    expect(refund.items.first.variant).to eq(variant)
  end

  it 'can refund three items' do
    variant = order.variants.first
    refund = stock_return.refunds.create(:variant_id => variant.id, :quantity => 3)
    expect(refund.items.count).to eq(3)
    expect(refund.items.first.variant).to eq(variant)
  end

  it 'creates refund items with a string quantity' do
    variant = order.variants.first
    refund = stock_return.refunds.create(:variant_id => variant.id, :quantity => '1')
    expect(refund.items.count).to eq(1)
    expect(refund.items.first.variant).to eq(variant)
  end

end