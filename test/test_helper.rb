require "simplecov"
require "minitest/autorun"
require "webmock/test_unit"

# limit coverage to /lib
cwd = File.expand_path(File.join(File.dirname(__FILE__), "../"))
SimpleCov.add_filter do |src_file|
  !src_file.filename.start_with?(File.join(cwd, "lib").to_s)
end
SimpleCov.start

class WebTestCase < MiniTest::Unit::TestCase

  def setup
    # HTTP request mocking
    @observers = [] # one per request
    @request_handler = lambda do |req|
      # not using webmock's custom assertions as those didn't seem to provide
      # sufficient flexibility
      fn = @observers.shift
      raise(TypeError, "missing request observer: #{req.inspect}") unless fn
      fn.call(req)
      true
    end
  end

  def teardown
    WebMock.reset!
    raise(TypeError, "unhandled request observer") unless @observers.length == 0
  end


end
