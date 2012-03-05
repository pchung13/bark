require 'spec_helper'

describe "ProductItem Model" do
  let(:product_item) { ProductItem.new }
  it 'can be created' do
    product_item.should_not be_nil
  end
end
