module Scry
  class ConcurrentRpc
    CONTEXT = Context.new

    private def get_requests(reader, input_channel)
      Log.logger.info "getting request..."
      content = Request.new(reader).read
      Log.logger.info "getting content..."
      input_channel.send content
    end

    private def handle_request(content, result_channel)
      Log.logger.info "Processing request..."
      Log.logger.info content
      request = Message.new(content).parse
      results = CONTEXT.dispatch(request)
    rescue ex
      results = [ResponseMessage.new(ex)]
    ensure
      Log.logger.info results
      Log.logger.info "End Processing request..."
      result_channel.send [results].flatten
    end

    def run
      Log.logger.info "server has started"
      input_channel = Channel(String | Nil).new

      spawn get_requests(reader, input_channel)

      channels = [] of Channel(String | Nil) | Channel(Array(Result))
      channels << input_channel

      until channels.empty?
        channel_index, data = Channel.select(channels.map &.receive_select_action)
        Log.logger.info "data received"
        Log.logger.info channel_index
        Log.logger.info data

        if channels[channel_index] == input_channel
          if data.nil?
            Log.logger.info "Input closed, no more data to come in current channel..."
            channels.delete_at(channel_index)
            next
          end

          content = data.as(String)
          result_channel = Channel(Array(Result)).new

          spawn handle_request(content, result_channel)

          channels << result_channel
        else
          results = data.as(Array(Result))
          Log.logger.info "Printing result output..."
          Log.logger.info results
          response = Response.new(results)
          response.write(writer)
          channels.delete_at(channel_index)
        end
      end
    rescue ex
      Log.logger.error(ex.inspect_with_backtrace) unless Log.logger.nil?
    ensure
      Log.logger.info("...your session has ended")
      Log.logger.close unless Log.logger.nil?
    end
  end
end
