module IqTriplestorage
  VERSION = "0.2.2"

  class BaseAdaptor
    attr_reader :host

    def initialize(host, options={})
      @host = URI.parse(host).normalize
      @username = options[:username]
      @password = options[:password]
    end

    def http_request(method, path, body=nil, headers={})
      uri = URI.join("#{@host}/", path)

      req = Net::HTTP.const_get(method.to_s.downcase.capitalize).new(uri.to_s)
      req.basic_auth(@username, @password) if (@username && @password)
      headers.each { |key, value| req[key] = value }
      req.body = body if body

      return Net::HTTP.new(uri.host, uri.port).request(req)
    end

  end
end
