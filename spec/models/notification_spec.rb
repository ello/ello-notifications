require 'rails_helper'

describe Notification do
  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:body) }
  it { is_expected.to respond_to(:metadata) }

  it 'defaults metadata to an empty hash' do
    notification = described_class.new
    expect(notification.metadata).to eq({})
  end

  it 'defaults include_alert to true' do
    notification = described_class.new
    expect(notification.include_alert).to eq(true)
  end

  it 'accepts arguments via the constructor' do
    notification = described_class.new({
      include_alert: false,
      title: 'The Title',
      body: 'Some Content',
      metadata: { some_key: 'value' }
    })

    expect(notification.include_alert).to eq(false)
    expect(notification.title).to eq('The Title')
    expect(notification.body).to eq('Some Content')
    expect(notification.metadata[:some_key]).to eq('value')
  end
end
