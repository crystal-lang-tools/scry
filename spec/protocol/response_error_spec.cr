require "../spec_helper.cr"

module Scry::Protocol
  describe ResponseError do
    it "sets UnkownErrorCode if no code provided" do
      response_error = ResponseError.new("something happened")
      response_error.code.should eq ErrorCodes::UnknownErrorCode
    end

    it "sets code if provided" do
      response_error = ResponseError.new("something happened", code: ErrorCodes::InvalidParams)
      response_error.code.should eq ErrorCodes::InvalidParams
    end

    it "will have an unknown error code if made with exception other than ProtocolException" do
      response_error = ResponseError.new(Exception.new)
      response_error.code.should eq ErrorCodes::UnknownErrorCode
    end

    it "will have code from exception if made with ProtocolException" do
      response_error = ResponseError.new(ProtocolException.new(code: ErrorCodes::InvalidRequest))
      response_error.code.should eq ErrorCodes::InvalidRequest
    end

    describe "#to_json" do
      it "serializes ErrorCodes correctly" do
        response_error = ResponseError.new("something happened", code: ErrorCodes::InvalidParams)
        response_error.to_json.should contain "-32602"
      end
    end
  end
end
