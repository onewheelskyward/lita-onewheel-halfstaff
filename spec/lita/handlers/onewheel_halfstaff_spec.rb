require 'spec_helper'

describe Lita::Handlers::OnewheelHalfstaff, lita_handler: true do
  it { is_expected.to route_command('halfstaff') }

end
