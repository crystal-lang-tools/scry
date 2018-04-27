require "../spec_helper"

module Scry
  BOOLEAN_METHODS = %w(!= & == ^ clone hash to_json to_s to_s to_yaml |)
  INT32_METHODS   = %w(- clone popcount)

  private macro it_completes(code, with_labels = nil, file = __FILE__, line = __LINE__)

    it "completes #{{{code}}.dump}" do
      {% if with_labels %}
        %expected = {{with_labels}}
      {% else %}
        %expected = _expected_labels_
      {% end %}

      %code = {{code}}
      cursor_location = [%code.lines.size, %code.size]

      _context_.test_send_did_open(_file_path_, %code)
      response = _context_.test_send_completion(_file_path_, %({"line":#{cursor_location[0]},"character":#{cursor_location[1]}}))
      results = response.as(Scry::ResponseMessage).result.as(Array(CompletionItem))
      labels = results.map(&.label)
      labels.sort.should eq(%expected.sort)

      results.each do |e|
        e.kind.should eq(_kind_)
      end
    end
  end

  describe CompletionProvider do
    _context_ = Context.new
    root_path = File.expand_path("spec/fixtures/completion/")
    _context_.test_send_init(root_path)
    _file_path_ = File.join(root_path, "tree.cr")

    context "module completion" do
      _kind_ = CompletionItemKind::Module

      it_completes("require \"arr", ["array"])
      it_completes("require \"./sa", ["sample"])
    end

    context "method completion" do
      _kind_ = CompletionItemKind::Method
      context "boolean methods" do
        _expected_labels_ = BOOLEAN_METHODS
        it_completes "a = true
                      a."

        it_completes "a = false
                      a."

        it_completes "a =
                        false
                    a."

        it_completes "a = 1
                      a = true
                      a."

        it_completes("a = true
                      a.to_", %w(to_json to_s to_s to_yaml))
      end
      context "int32" do
        _expected_labels_ = INT32_METHODS

        (1..10).each do |i|
          it_completes "a = #{i}
                        a."
        end

        it_completes "a = true
                      a = 1
                      a."
      end
    end
  end
end
