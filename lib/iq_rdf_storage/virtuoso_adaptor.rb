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
      res = sparql_pull("CLEAR GRAPH <#{uri}>") # XXX: s/CLEAR/DROP/ was rejected (405)
      return res == "200" # XXX: always returns 409
    end

    # uses push method if `rdf_data` is provided, pull otherwise
    def update(uri, rdf_data=nil)
      reset(uri)

      if rdf_data
        res = sparql_push(uri, rdf_data.strip)
      else
        res = sparql_pull(%{LOAD "#{uri}" INTO GRAPH <#{uri}>})
      end

      return res == "200" # XXX: always returns 409
    end

    def sparql_push(uri, rdf_data)
      filename = uri.gsub(/[^0-9A-Za-z]/, "_") # XXX: too simplistic?
      path = "/DAV/home/#{@username}/rdf_sink/#{filename}"
      res = http_request("PUT", path, rdf_data, {
        "Expect" => "100-continue"
      })
      return res.code
    end

    def sparql_pull(query)
      path = "/DAV/home/#{@username}/rdf_sink" # XXX: shouldn't this be /sparql?
      res = http_request("POST", path, query, {
        "Content-Type" => "application/sparql-query"
      })
      return res.code
    end

    def http_request(method, path, body, headers={})
      uri = URI.parse("#{@host}:#{@port}#{path}")

      req = Net::HTTP.const_get(method.downcase.capitalize).new(uri.to_s)
      req.basic_auth(@username, @password)
      headers.each { |key, value| req[key] = value }
      req.body = body

      return Net::HTTP.new(uri.host, uri.port).request(req)
    end

  end
end
