require "../spec_helper"

module Scry
  describe Request do
    it "reads content from IO" do
      io = IO::Memory.new(SIMPLE_MESSAGE)
      request = Request.new(io)

      request.content.should eq("Hello")
      request.headers.content_length.should eq(5)
    end
  end

  SIMPLE_MESSAGE = %(Content-Length: 5\r\n\r\nHello\r\n)
end
