require "../spec_helper"

module Scry
  describe Scry do
    it "compiles scry binary" do
      Process.run("shards", ["build"])
      File.exists?("bin/scry").should be_true
    end

    it "executes scry binary" do
      data = IO::Memory.new <<-DATA
      Content-Length: #{INITIALIZATION_EXAMPLE.bytesize}
      
      #{INITIALIZATION_EXAMPLE}Content-Length: #{INITIALIZED_EXAMPLE.bytesize}
      
      #{INITIALIZED_EXAMPLE}Content-Length: #{SHUTDOWN_EXAMPLE.bytesize}
      
      #{SHUTDOWN_EXAMPLE}
      DATA
      output = String.build do |io|
        Process.run("bin/scry", input: data, output: io)
      end
      output.should contain("capabilities")
    end
  end
end
