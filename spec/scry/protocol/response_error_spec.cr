require "../../spec_helper.cr"

module Scry::Protocol
  describe ResponseError do
    it "sets UnkownErrorCode if no code provided" do
      response_error = ResponseError.new("something happened", nil)
      response_error.to_json.should contain "-32001"
    end

    it "sets code if provided" do
      response_error = ResponseError.new("something happened", nil, ErrorCodes::InvalidParams)
      response_error.to_json.should contain "-32602"
    end
  end
end