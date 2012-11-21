require File.join(File.expand_path(File.dirname(__FILE__)), "test_helper")

require "iq_triplestorage"

class BaseTest < MiniTest::Unit::TestCase

  def test_version
    assert IqTriplestorage::VERSION.is_a?(String)
  end

  def test_host_normalization
    host = "http://example.org"
    adaptor = IqTriplestorage::BaseAdaptor.new(host)
    assert_equal "/", adaptor.host.path

    host = "http://example.org/"
    adaptor = IqTriplestorage::BaseAdaptor.new(host)
    assert_equal "/", adaptor.host.path

    host = "http://example.org/foo"
    adaptor = IqTriplestorage::BaseAdaptor.new(host)
    assert_equal "/foo", adaptor.host.path

    host = "http://example.org/foo/"
    adaptor = IqTriplestorage::BaseAdaptor.new(host)
    assert_equal "/foo/", adaptor.host.path
  end

end
