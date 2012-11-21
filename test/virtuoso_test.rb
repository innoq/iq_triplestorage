require File.join(File.expand_path(File.dirname(__FILE__)), "test_helper")

require "base64"

require "iq_triplestorage/virtuoso_adaptor"

class VirtuosoTest < WebTestCase

  def setup
    super
    WebMock.stub_request(:any, /.*example.org.*/).with(&@request_handler).
        to_return do |req|
          { :status => req.uri.to_s.end_with?("/rdf_sink") ? 200 : 201 }
        end

    @host = "http://example.org:8080"
    @username = "foo"
    @password = "bar"
    @adaptor = IqTriplestorage::VirtuosoAdaptor.new(@host,
        :username => @username, :password => @password)
  end

  def test_reset
    uri = "http://example.com/foo"

    @observers << lambda do |req|
      ensure_basics(req)
      assert_equal :post, req.method
      assert_equal "/DAV/home/#{@username}/rdf_sink", req.uri.path
      assert_equal "application/sparql-query", req.headers["Content-Type"]
      assert_equal "CLEAR GRAPH <#{uri}>", req.body
    end
    assert @adaptor.reset(uri)
  end

  def test_pull
    uri = "http://example.com/bar"

    @observers << lambda do |req|
      assert_equal "CLEAR GRAPH <#{uri}>", req.body
    end
    @observers << lambda do |req|
      assert_equal :post, req.method
      assert_equal "/DAV/home/#{@username}/rdf_sink", req.uri.path
      assert_equal "application/sparql-query", req.headers["Content-Type"]
      assert_equal %(LOAD "#{uri}" INTO GRAPH <#{uri}>), req.body
    end
    assert @adaptor.update(uri)
  end

  def test_push
    uri = "http://example.com/baz"

    rdf_data = <<-EOS.strip
<?xml version="1.0" encoding="UTF-8"?>
<rdf:RDF xmlns="http://try.iqvoc.net/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:dct="http://purl.org/dc/terms/"
    xmlns:coll="http://try.iqvoc.net/collections/"
    xmlns:schema="http://try.iqvoc.net/schema#">
  <rdf:Description rdf:about="http://try.iqvoc.net/model_building">
    <rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>
    <skos:prefLabel xml:lang="en">Model building</skos:prefLabel>
    <skos:narrower rdf:resource="http://try.iqvoc.net/model_rocketry"/>
    <skos:narrower rdf:resource="http://try.iqvoc.net/radio-controlled_modeling"/>
    <skos:narrower rdf:resource="http://try.iqvoc.net/scale_modeling"/>
    <skos:broader rdf:resource="http://try.iqvoc.net/achievement_hobbies"/>
  </rdf:Description>
</rdf:RDF>
    EOS

    @observers << lambda do |req|
      assert_equal "CLEAR GRAPH <#{uri}>", req.body
    end
    @observers << lambda do |req|
      assert_equal :put, req.method
      path = req.uri.path
      assert path.start_with?("/DAV/home/#{@username}/rdf_sink/")
      assert_equal 5, path.count("/")
      assert_equal "application/rdf+xml", req.headers["Content-Type"]
      assert_equal rdf_data, req.body
    end
    assert @adaptor.update(uri, rdf_data, "application/rdf+xml")
  end

  def test_batch
    data = {
      "http://example.com/foo" => "<aaa> <bbb> <ccc> .\n<ddd> <eee> <fff> .",
      "http://example.com/bar" => "<ggg> <hhh> <iii> .\n<jjj> <kkk> <lll> ."
    }

    @observers << lambda do |req|
      assert_equal :post, req.method
      path = req.uri.path
      assert path.start_with?("/DAV/home/#{@username}/")
      assert_equal 4, path.count("/")
      assert_equal "application/sparql-query", req.headers["Content-Type"]
      data.keys.each do |graph_uri|
        assert req.body.include?("CLEAR GRAPH <#{graph_uri}>")
      end
    end
    @observers << lambda do |req|
      assert_equal :post, req.method
      path = req.uri.path
      assert path.start_with?("/DAV/home/#{@username}/")
      assert_equal 4, path.count("/")
      assert_equal "application/sparql-query", req.headers["Content-Type"]
      data.each do |graph_uri, ntriples|
        assert req.body.include?(<<-EOS)
INSERT IN GRAPH <#{graph_uri}> {
#{ntriples}
}
        EOS
      end
    end
    assert @adaptor.batch_update(data)
  end

  def ensure_basics(req) # TODO: rename
    assert_equal @host, "#{req.uri.scheme}://#{req.uri.hostname}:#{req.uri.port}"

    if auth_header = req.headers["Authorization"]
      auth = Base64.encode64([@username, @password].join(":")).strip
      assert_equal auth, auth_header
    else
      # MockWeb appears to prevent the Authorization header being set, instead
      # retaining username and password in URI
      assert req.uri.to_s.
          start_with?("#{req.uri.scheme}://#{@username}:#{@password}@")
    end
  end

end
