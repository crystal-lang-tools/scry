require "../spec_helper"
require "../../src/scry/request"

module Scry

  describe Request do

    it "reads content from IO" do
      io = IO::Memory.new(SIMPLE_MESSAGE)
      Request.new(io).read.should eq("Hello")
    end

  end

  SIMPLE_MESSAGE =
      %(Content-Length: 5\r\n\r\nHello\r\n)

end
