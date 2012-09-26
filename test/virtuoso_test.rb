require "minitest/autorun"
require "iq_rdf_storage/virtuoso_adaptor"

class VirtuosoTest < MiniTest::Unit::TestCase

  def setup
    @adaptor = IqRdfStorage::VirtuosoAdaptor.new("http://virtuoso.led.innoq.com",
        80, "dba", "...")
  end

  def test_api
    uri = "http://try.iqvoc.net/model_building.rdf"

    assert @adaptor.reset(uri)
    assert @adaptor.update(uri)
  end

end
