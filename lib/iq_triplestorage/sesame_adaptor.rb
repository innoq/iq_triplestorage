require "net/http"
require "cgi"

require "iq_triplestorage"

class IqTriplestorage::SesameAdaptor
  attr_reader :host

  def initialize(host, repository, options={})
    @host = URI.parse(host).normalize
    @repo = repository
    @username = options[:username]
    @password = options[:username]
  end

  # expects a hash of N-Triples by graph URI
  def batch_update(triples_by_graph)
    path = "/repositories/#{CGI.escape(@repo)}/statements"
    path = URI.join("#{@host}/", path[1..-1]).path

    data = triples_by_graph.map do |graph_uri, ntriples|
      "<#{graph_uri}> {\n#{ntriples}\n}\n"
    end.join("\n\n")

    http_request("POST", path, data, { "Content-Type" => "application/x-trig" })
  end

  # converts N-Triples to N-Quads
  def triples_to_quads(triples, context)
  end

  def http_request(method, path, body, headers={}) # XXX: largely duplicates VirtuosoAdaptor's
    uri = URI.join("#{@host.to_s}/", path)

    req = Net::HTTP.const_get(method.to_s.downcase.capitalize).new(uri.to_s)
    req.basic_auth(@username, @password) if (@username && @password)
    headers.each { |key, value| req[key] = value }
    req.body = body

    return Net::HTTP.new(uri.host, uri.port).request(req)
  end

end
