class Rack::Attack
  ### Throttle requests ###
  throttle('req/ip', limit: 100, period: 1.minute) do |req|
    req.ip # Limits requests to 100 per minute per IP
  end

  ### Protect Login from Brute-Force Attacks ###
  throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    if req.path == '/login' && req.post?
      req.ip
    end
  end

  ### Blocklist Specific IPs (Example) ###
  blocklist('block bad IPs') do |req|
    ['192.168.1.100', '203.0.113.1'].include?(req.ip) # Replace with actual abusive IPs
  end

  ### Allowlist Trusted IPs (Example) ###
  safelist('allow trusted IPs') do |req|
    ['127.0.0.1', '192.168.0.1'].include?(req.ip) # Replace with actual trusted IPs
  end

  ### Respond with a Custom Error for Blocked Requests ###
  self.throttled_response = lambda do |env|
    [429, { 'Content-Type' => 'application/json' }, [{ error: 'Too many requests. Please try again later.' }.to_json]]
  end
end