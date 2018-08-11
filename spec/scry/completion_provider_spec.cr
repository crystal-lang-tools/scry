require "../spec_helper"

module Scry
  BOOLEAN_METHODS = %w(!= & == ^ clone hash to_json to_s to_s to_unsafe to_yaml |)
  INT32_METHODS   = %w(- clone popcount)

  private macro it_completes(code, with_labels = nil)

    it "completes #{{{code}}.dump}" do
      {% if with_labels %}
        %expected = {{with_labels}}
      {% else %}
        %expected = _expected_labels_
      {% end %}

      %code = {{code}}
      cursor_location = { %code.lines.size, %code.size }

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
    _file_path_ = File.join(root_path, "sample.cr")

    context "module completion" do
      _kind_ = CompletionItemKind::Module

      it_completes("require \"arr", ["array"])
      it_completes("require \"./tr", ["tree"])
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
                      a.to_", %w(to_json to_s to_s to_unsafe to_yaml))
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
        it_completes "def blah(a : A)
                      end
                      def blah_2(a : Node)
                          a = 2
                          a."
      end

      context "tree instance methods" do
        _expected_labels_ = %w(add print)

        it_completes "abc = Node.new
                      abc."

        it_completes "abc =
                      Node.new
                      abc."
        it_completes "a = true
                      a = Node.new
                      a."

        it_completes "a = true
                      a = Node.new(1)
                      a."

        it_completes "a = true
                      a = Node.new(true)
                      a."

        it_completes "def blah(a : Node)
                        a."

        it_completes "def blah(a : Array)
                      end
                      def blah_2(a : Node)
                          a."

        it_completes "property a : Node
                      def blah(a : A)
                        @a."

        it_completes "getter a : Node
                      def blah(a : A)
                        @a."

        it_completes "setter a : Node
                      def blah(a : A)
                          @a."

        it_completes "a = 2
                      def blah_2(a : Node)
                          a."

        it_completes "Node.", %w(new)

        it_completes "a = B.new
                      a.", %w(method)
      end
    end

    context "module, struct and class name completion" do
      _kind_ = CompletionItemKind::Class
      it_completes("A", %w(Array Atomic ArgumentError AtExitHandlers))
      it_completes(" ::A", %w(Array Atomic ArgumentError AtExitHandlers))
      it_completes(" ::", %w())
      it_completes("JSON::P", %w(ParseException Parser PullParser))
      it_completes("JSON::Pa", %w(ParseException Parser))
      it_completes("JSON::", %w(Any Builder Error Lexer Lexer::IOBased Lexer::StringBased MappingError ParseException Parser PullParser Serializable Serializable::Strict Serializable::Unmapped Token))
      it_completes("JSO", %w(JSON JSON::Any JSON::Builder JSON::Error JSON::Lexer JSON::Lexer::IOBased JSON::Lexer::StringBased JSON::MappingError JSON::ParseException JSON::Parser JSON::PullParser JSON::Serializable JSON::Serializable::Strict JSON::Serializable::Unmapped JSON::Token))
    end
  end
end
