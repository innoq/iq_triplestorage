require 'net/http'
require 'cgi'

module IqRdfStorage
  class VirtuosoAdaptor

    def initialize(host, port=80, username=nil, password=nil)
      @endpoint = "#{host}:#{port}/sparql"
      @username = username
      @password = password
    end

    def reset(uri)
      return true # TODO
    end

    def update(uri, options)
      reset(uri)
      # Virtuoso pragmas for instructing SPARQL engine to perform an HTTP GET
      # using the URI in as Data Source URL
      query = "DEFINE get:soft \"replace\" SELECT DISTINCT * FROM <#{uri}> WHERE {?s ?p ?o}"
      data = self.class.sparql_query(query, @endpoint) # TODO: error handling
    end

    def self.sparql_query(query, base_uri)
      params = {
        "default-graph" => "",
        "should-sponge" => "soft",
        "query" => query,
        "debug" => "on",
        "timeout" => "",
        "format" => "application/json", # XXX: ?
        "save" => "display",
        "fname" => ""
      }

      uri = base_uri + "?" + params.
          map { |key, val| "#{CGI.escape(key)}=#{CGI.escape(val)}" }.join("&")
      uri = URI.parse(uri)

      req = Net::HTTP::Get.new(uri.to_s)
      req.basic_auth(@username, @password) if @username || @password
      req["Content-Type"] = "application/sparql-query"

      res = Net::HTTP.new(uri.host, uri.port).request(req)
      return res.code == "200"
    end

  end
end
