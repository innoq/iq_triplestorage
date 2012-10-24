require "simplecov"

# limit coverage to /lib
cwd = File.expand_path(File.join(File.dirname(__FILE__), "../"))
SimpleCov.add_filter do |src_file|
  !src_file.filename.start_with?(File.join(cwd, "lib").to_s)
end
SimpleCov.start
