module Lita
  module Handlers
    class OnewheelHalfstaff < Handler
      route /^halfstaff$/,
            :get_flag_status,
            command: true

      Lita.register_handler(self)
    end
  end
end
