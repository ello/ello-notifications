require 'spec_helper'

RSpec.shared_examples 'a notification with' do
  # shared example expects that a number of params are defined as lets
  # in the calling spec -  e.g. `let(:title) { 'expected title' }`

  it 'sets the correct body' do
    expect(subject.body).to eq(body)
  end

  it 'sets the correct include_alert flag' do
    expect(subject.include_alert).to eq(include_alert)
  end

  it 'has the correct destination_user_id' do
    expect(subject.metadata[:destination_user_id]).to eq(destination_user_id)
  end

  it 'has the correct type' do
    expect(subject.metadata[:type]).to eq(type)
  end

  it 'sets the correct application_target' do
    expect(subject.metadata[:application_target]).to eq(application_target)
  end

  it 'sets the correct web_url' do
    expect(subject.metadata[:web_url]).to eq(web_url)
  end
end

