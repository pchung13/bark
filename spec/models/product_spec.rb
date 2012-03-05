require 'spec_helper'

describe "Product Model" do
  let(:product) { Product.new }
  it 'can be created' do
    product.should_not be_nil
  end
end
