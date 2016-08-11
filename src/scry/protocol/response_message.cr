module Scry

  class ResponseMessage

    private getter id : Int32

    def initialize(@id)
    end

    def compose_json(io)
      io.json_object do |object|
        object.field "jsonrpc", "2.0"
        object.field "id", @id
        object.field "result" do
          yield io
        end
      end
    end
  end

end
