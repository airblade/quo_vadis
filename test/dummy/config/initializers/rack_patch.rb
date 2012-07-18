# TODO: remove once on Rack 1.3.0.
# https://github.com/jnicklas/capybara/issues/87#issuecomment-2106788
module Rack
  module Utils

    def escape(s)
      CGI.escape s.to_s
    end

    def unescape(s)
      CGI.unescape s
    end

  end
end

