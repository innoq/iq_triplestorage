require "net/http"

module IqRdfStorage
  class VirtuosoAdaptor

    def initialize(host, port, username, password)
      @host = host
      @port = port
      @username = username
      @password = password
    end

    def reset(uri)
      res = sparql("CLEAR GRAPH <#{uri}>") # XXX: s/CLEAR/DROP/ was rejected (405)
      return res == "200" # XXX: always returns 409
    end

    def update(uri)
      reset(uri)

      res = sparql(%{LOAD "#{uri}" INTO GRAPH <#{uri}>})
      return res == "200" # XXX: always returns 409
    end

    def sparql(query)
      path = "/DAV/home/#{@username}/rdf_sink" # XXX: shouldn't this be /sparql?

      uri = URI.parse("#{@host}:#{@port}#{path}")
      req = Net::HTTP::Post.new(uri.to_s)
      req.basic_auth(@username, @password)
      req["Content-Type"] = "application/sparql-query"
      req.body = query

      res = Net::HTTP.new(uri.host, uri.port).request(req)
      return res.code
    end

  end
end
