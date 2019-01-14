require "../../spec_helper.cr"

module Scry::Protocol
  describe ResponseMessage do
    it "can be made with an Exception" do
      response_message = ResponseMessage.new(Exception.new("something happened"))
      err = response_message.error.as(ResponseError)
      err.code.should eq ErrorCodes::UnknownErrorCode
    end

    it "can be made with a ProtocolException" do
      response_message = ResponseMessage.new(ProtocolException.new(code: ErrorCodes::InvalidRequest))
      err = response_message.error.as(ResponseError)
      err.code.should eq ErrorCodes::InvalidRequest
    end
  end
end