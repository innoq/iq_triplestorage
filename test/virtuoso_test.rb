require "minitest/autorun"
require "iq_rdf_storage/virtuoso_adaptor"

class VirtuosoTest < MiniTest::Unit::TestCase

  def setup
    @adaptor = IqRdfStorage::VirtuosoAdaptor.new
  end

  def test_api
    assert_nil @adaptor.reset("http://example.org")
    assert_nil @adaptor.update("http://example.org", "lipsum")
  end

end
