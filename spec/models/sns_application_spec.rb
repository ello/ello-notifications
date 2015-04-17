require 'rails_helper'

describe SnsApplication do
  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:platform).in_array(['APNS', 'GCM']) }
    it { is_expected.to validate_uniqueness_of(:bundle_identifier).scoped_to(:platform) }

    it 'adds a validation error when the bundle_identifier is not formatted correctly' do
      not_ids = []
      not_ids << 'co.ello'
      not_ids << 'coelloello'
      not_ids << 'co-ello-ello'

      not_ids.each do |id|
        subject.bundle_identifier = id
        subject.valid? # run validations
        expect(subject.errors[:bundle_identifier]).to include('not a valid bundle id')
      end
    end

    it 'does not add a validation error when the bundle_identifier is formatted correctly' do
      subject.bundle_identifier = 'co.ello.ello'
      subject.valid? # run validations
      expect(subject.errors[:bundle_identifier]).to be_empty
    end
  end
end
