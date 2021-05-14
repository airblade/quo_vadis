QuoVadis.configure do
  # Cannot use the __Host- prefix in a non-SSL environment.
  # https://tools.ietf.org/html/draft-west-cookie-prefixes-05#section-3.2
  cookie_name 'qv'

  session_lifetime 1.week
end
