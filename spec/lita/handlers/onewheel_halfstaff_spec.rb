require 'spec_helper'
require 'rest-client'

describe Lita::Handlers::OnewheelHalfstaff, lita_handler: true do
  before do
    mock = File.open('spec/fixtures/halfstaff.html').read
    allow(RestClient).to receive(:get) { mock }
  end

  it { is_expected.to route_command('halfstaff') }

  it 'gives half-staff status' do
    send_command 'halfstaff'
  end
end
