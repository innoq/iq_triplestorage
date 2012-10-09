require "minitest/autorun"
require "iq_rdf_storage/virtuoso_adaptor"

class VirtuosoTest < MiniTest::Unit::TestCase

  def setup
    @adaptor = IqRdfStorage::VirtuosoAdaptor.new("http://virtuoso.led.innoq.com",
        80, "dba", "...")
  end

  def test_pull
    uri = "http://try.iqvoc.net/model_building.rdf"

    assert @adaptor.update(uri)
  end

  def test_push
    uri = "http://try.iqvoc.net/model_building.rdf"

    rdf_data = <<-EOS
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
    rdf_data.strip!

    assert @adaptor.update(uri, rdf_data, "application/rdf+xml")
  end

end
