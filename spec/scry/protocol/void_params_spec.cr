require "../../spec_helper"

module Scry
  module Protocol
    describe VoidParams do
      it "creates from json" do
        void_params = VoidParams.from_json("{}")
        void_params.is_a?(VoidParams).should be_true
      end

      it "raises a JSON::ParseException if non empty JSON is supplied" do
        expect_raises(JSON::ParseException) do
          void_params = VoidParams.from_json(%({ "key": "value" }))
        end
      end

      it "will render as JSON" do
        void_params = VoidParams.from_json("{}")
        void_params.to_json.should eq("{}")
      end
    end
  end
end
