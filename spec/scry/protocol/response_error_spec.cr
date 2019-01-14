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

    it "will have an unknown error code if made with exception other than ProtocolException" do
      response_error = ResponseError.new(Exception.new("something happened"))
      response_error.to_json.should contain "-32001"
    end

    it "will have code from exception if made with ProtocolException" do
      response_error = ResponseError.new(ProtocolException.new("something happened", code: ErrorCodes::InvalidRequest))
      response_error.to_json.should contain "-32600"
    end
  end
end