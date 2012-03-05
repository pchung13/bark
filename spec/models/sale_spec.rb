require 'spec_helper'

describe "Sale Model" do
  let(:sale) { Sale.new }
  it 'can be created' do
    sale.should_not be_nil
  end
end
