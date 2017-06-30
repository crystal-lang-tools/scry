require "../spec_helper"

module Scry
  describe Headers do
    it "returns content length" do
      headers = Headers.new
      headers.add "Content-Length: 5"
      headers.content_length.should eq(5)
    end

    it "raises an error if there is no content_length" do
      headers = Headers.new
      headers.add "Content-Type: application/json"
      expect_raises(MalformedHeaderError) { headers.content_length }
    end
  end
end
