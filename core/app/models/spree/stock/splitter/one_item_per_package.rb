module Spree
  module Stock
    module Splitter
      class OneItemPerPackage < Base
        cattr_accessor :shipping_category_names do
          []
        end

        def split(packages)
          packages_to_be_processed = packages.select do |package|
            package.contents.any? do |item|
              self.class.shipping_category_names.include?(item.line_item.variant.shipping_category.name)
            end
          end

          packages_to_be_processed.each do |package|
            packages.delete(package)
            package.contents.each do |item|
              item.quantity.times do
                packages << build_package([item])
              end
            end
          end

          packages
        end
      end
    end
  end
end
