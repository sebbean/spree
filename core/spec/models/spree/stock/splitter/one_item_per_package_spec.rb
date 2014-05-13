require 'spec_helper'

module Spree
  module Stock
    module Splitter
      describe OneItemPerPackage do
        let(:line_item1) do
          line_item = build(:line_item, variant: build(:variant))
          line_item.variant.product.shipping_category = create(:shipping_category, name: 'Mattress')
          line_item
        end

        before do
          Spree::Stock::Splitter::OneItemPerPackage.shipping_category_names = ["Mattress"]
        end

        let(:packer) { build(:stock_packer) }

        subject { Spree::Stock::Splitter::OneItemPerPackage.new(packer) }

        it "allows only one item in each package from the 'Mattress' shipping category" do
          package1 = Package.new(packer.stock_location, packer.order)
          package1.add line_item1, 2

          packages = subject.split([package1])
          expect(packages.count).to eq(2)
        end

      end
    end
  end
end
