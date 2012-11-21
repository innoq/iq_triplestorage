module IqTriplestorage
  VERSION = "0.2.1"

  class BaseAdaptor
    attr_reader :host

    def initialize(host, options={})
      @host = URI.parse(host).normalize
      @username = options[:username]
      @password = options[:password]
    end

    def http_request(method, path, body, headers={})
      uri = URI.join("#{@host}/", path)

      req = Net::HTTP.const_get(method.to_s.downcase.capitalize).new(uri.to_s)
      req.basic_auth(@username, @password) if (@username && @password)
      headers.each { |key, value| req[key] = value }
      req.body = body

      return Net::HTTP.new(uri.host, uri.port).request(req)
    end

  end
end
