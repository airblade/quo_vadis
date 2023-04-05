module QuoVadis
  module Constraints

    class LoggedIn
      def self.matches?(request)
        cookies = ActionDispatch::Cookies::CookieJar.build(request, request.cookies)
        session_id = cookies.encrypted[QuoVadis.cookie_name]
        session_id && QuoVadis::Session.find_by(id: session_id)
      end
    end

  end
end
