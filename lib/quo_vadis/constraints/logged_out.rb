module QuoVadis
  module Constraints

    class LoggedOut
      def self.matches?(request)
        cookies = ActionDispatch::Cookies::CookieJar.build(request, request.cookies)
        session_id = cookies.encrypted[QuoVadis.cookie_name]
        session_id.nil? || QuoVadis::Session.find_by(id: session_id).nil?
      end
    end

  end
end
