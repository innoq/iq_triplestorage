require File.join(File.expand_path(File.dirname(__FILE__)), "test_helper")

require "iq_triplestorage"

class CoreTest < MiniTest::Unit::TestCase

  def test_version
    assert IqTriplestorage::VERSION.is_a?(String)
  end

end
