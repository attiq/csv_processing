require 'rails_helper'

RSpec.describe User, type: :model do

  describe '#CSV Processing' do
    it { expect(User.process_csv).to eq true }
  end

end