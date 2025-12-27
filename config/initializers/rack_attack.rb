class Rack::Attack
  # Throttle login attempts for a given email address
  throttle("logins/email", limit: 5, period: 60.seconds) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.params["user"]["email"].to_s.downcase.gsub(/\s+/, "")
    end
  end

  # Throttle signup attempts by IP address
  throttle("signups/ip", limit: 5, period: 5.minutes) do |req|
    if req.path == "/users" && req.post?
      req.ip
    end
  end

  # Throttle API requests by IP address
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets")
  end

  # Throttle email account creation
  throttle("email_accounts/ip", limit: 10, period: 1.hour) do |req|
    if req.path == "/email_accounts" && req.post?
      req.ip
    end
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |env|
    retry_after = env["rack.attack.match_data"][:period]
    [
      429,
      { "Content-Type" => "text/plain", "Retry-After" => retry_after.to_s },
      ["Too many requests. Please try again later.\n"]
    ]
  end
end
