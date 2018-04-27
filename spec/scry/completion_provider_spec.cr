require "../spec_helper"

module Scry
  BOOLEAN_METHODS = %w(!= & == ^ clone hash to_json to_s to_s to_yaml |)

  private macro it_completes(code, with_labels, file = __FILE__, line = __LINE__)

    it "completes #{{{code}}.dump}" do
      %code = {{code}}
      cursor_location = nil
      location = %code.lines.each_with_index do |line, line_number_0|
        if column_number = line.index('‸')
          cursor_location = [line_number_0 + 1, column_number + 1]
        end

        if column_number = line.index('༓')
          cursor_location = [line_number_0 + 1, column_number + 1]
        end
      end

      unless cursor_location
        cursor_location = [0, %code.size - 1]
      end
      %code = %code.gsub("༓", ".").gsub("‸", "")
      _context_.test_send_did_open(_file_path_, %code)
      response = _context_.test_send_completion(_file_path_, %({"line":#{cursor_location[0]},"character":#{cursor_location[1]}}))
      results = response.as(Scry::ResponseMessage).result.as(Array(CompletionItem))
      labels = results.map(&.label)
      labels.sort.should eq({{with_labels}}.sort)

      results.each do |e|
        e.kind.should eq(_kind_)
      end
    end
  end

  describe CompletionProvider do
    context "module completion" do
      _kind_ = CompletionItemKind::Module
      _context_ = Context.new
      root_path = File.expand_path("spec/fixtures/completion/")
      _context_.test_send_init(root_path)

      _file_path_ = File.join(root_path, "tree.cr")

      it_completes("require \"arr", ["array"])
      it_completes("require \"./sa", ["sample"])
    end
    context "method completion" do
      _kind_ = CompletionItemKind::Method
      _context_ = Context.new
      root_path = File.expand_path("spec/fixtures/completion/")
      _context_.test_send_init(root_path)

      _file_path_ = File.join(root_path, "tree.cr")

      it_completes("a = true
                    a༓", BOOLEAN_METHODS)
    end
  end
end
