require 'spec_helper'
require 'rest-client'
require 'timecop'

describe Lita::Handlers::OnewheelHalfstaff, lita_handler: true do
  before do
    mock = File.open('spec/fixtures/halfstaff.html').read
    allow(RestClient).to receive(:get) { mock }
  end

  it { is_expected.to route_command('halfstaff') }

  it 'gives half-staff status' do
    send_command 'halfstaff'
    expect(["Everything's cool, yo.", "No half staff known."].include? replies.last).to be true
  end

  it 'gives half-staff affirmative' do
    Timecop.freeze(Time.local(2016, 2, 26, 10, 5, 0)) do
      send_command 'halfstaff'
      puts replies.last
      expect(replies.count).to eq(2)
      expect(replies[0]).to eq('KANSAS ONLY - Honoring  the victims of the Hesston shootings - http://www.flagsexpress.com/Articles.asp?ID=546')
      expect(replies[1]).to eq('MINNESOTA ONLY - Honoring Marine Corps Sergeant and Delano, Minnesota resident Dillion J. Semolina - http://www.flagsexpress.com/Articles.asp?ID=545')
    end
  end
end
