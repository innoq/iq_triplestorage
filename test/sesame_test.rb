require File.join(File.expand_path(File.dirname(__FILE__)), "test_helper")

require "base64"

require "iq_triplestorage/sesame_adaptor"

class SesameTest < WebTestCase

  def setup
    super
    WebMock.stub_request(:any, /.*example.org.*/).with(&@request_handler).
        to_return { |req| { :status => 204 } }

    @host = "http://example.org/sesame"
    @repo = "test"
    @username = "foo"
    @password = "bar"

    @adaptor = IqTriplestorage::SesameAdaptor.new(@host, :repository => @repo,
        :username => @username, :password => @password)
  end

  def test_batch
    data = {
      "http://example.com/foo" => "<aaa> <bbb> <ccc> .\n<ddd> <eee> <fff> .",
      "http://example.com/bar" => "<ggg> <hhh> <iii> .\n<jjj> <kkk> <lll> ."
    }

    @observers << lambda do |req|
      assert_equal :delete, req.method
      assert_equal "/sesame/repositories/#{CGI.escape(@repo)}/statements",
          req.uri.path
      # XXX: currently cannot test query parameters due to WebMock issues:
      # https://github.com/bblimke/webmock/issues/226
      # https://github.com/bblimke/webmock/issues/227
      #assert_equal "context=...", req.uri.query
    end
    @observers << lambda do |req|
      assert_equal :post, req.method
      assert_equal "/sesame/repositories/#{CGI.escape(@repo)}/statements",
          req.uri.path
      assert_equal "application/x-trig", req.headers["Content-Type"]
      data.each do |graph_uri, ntriples|
        assert req.body.include?(<<-EOS)
<#{graph_uri}> {
#{ntriples}
}
        EOS
      end
    end
    assert_equal true, @adaptor.batch_update(data)
  end

end
