require "json"

module Scry

  class ErrorMessage

    private getter ex : Exception

    def initialize(@ex)
    end

    def to_json
      JSON.build do |json|
        json.object do
          json.field "jsonrpc", "2.0"
          json.field "id", nil
          json.field "error" do
            json.object do
              json.field "code", -32001
              json.field "message", (ex.message || "Unknown error")
              json.field "data" do
                json.array do
                  ex.backtrace.each do |trace|
                    json.string trace
                  end
                end
              end
            end
          end
        end
      end
    end
  end

end
