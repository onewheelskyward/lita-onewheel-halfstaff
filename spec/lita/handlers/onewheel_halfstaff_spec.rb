require 'spec_helper'
require 'rest-client'
require 'timecop'

describe Lita::Handlers::OnewheelHalfstaff, lita_handler: true do
  before do
    mock = File.open('spec/fixtures/halfstaff.html').read
    allow(RestClient).to receive(:get) { mock }
  end

  it { is_expected.to route_command('halfstaff') }
  it { is_expected.to route_command('halfstaff history') }
  it { is_expected.to route_command('halfmast') }
  it { is_expected.to route_command('halfmast history') }

  it 'gives half-staff status' do
    Timecop.freeze(Time.local(2016, 2, 2, 10, 5, 0)) do
      send_command 'halfstaff'
      expect(["Everything's cool, yo.", "No half staff known."].include? replies.last).to be true
    end
  end

  it 'gives half-staff affirmative' do
    Timecop.freeze(Time.local(2016, 2, 26, 10, 5, 0)) do
      send_command 'halfstaff'
      expect(replies.count).to eq(2)
      expect(replies[0]).to eq('KANSAS ONLY - Honoring  the victims of the Hesston shootings - www.flagsexpress.com/Articles.asp?ID=546')
      expect(replies[1]).to eq('MINNESOTA ONLY - Honoring Marine Corps Sergeant and Delano, Minnesota resident Dillion J. Semolina - www.flagsexpress.com/Articles.asp?ID=545')
    end
  end

  it 'checks some edge cases for multi-day half staffs.' do
    Timecop.freeze(Time.local(2016, 3, 9, 10, 5, 0)) do
      send_command 'halfstaff'
      expect(replies.count).to eq(2)
      expect(replies[0]).to eq('COLORADO ONLY - Honoring Las Animas County Deputy Sheriff Travis Russell  - www.flagsexpress.com/Articles.asp?ID=552')
      expect(replies[1]).to eq('ENTIRE UNITED STATES - Honoring Nancy Reagan  - www.flagsexpress.com/Articles.asp?ID=550')
    end
  end

  it 'will return history link' do
    send_command 'halfstaff history'
    expect(replies.last).to eq('https://en.wikipedia.org/wiki/Half-mast')
  end
end
