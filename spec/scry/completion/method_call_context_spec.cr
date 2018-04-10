require "../../spec_helper"

private def parse_example(code)
  match = code.match(/(?<target>.*)‸(?<method>.*)/).not_nil!
  end_location = code.index("‸")
  text = code.gsub("‸", ".")[0..end_location.not_nil! - 1]

  Scry::Completion::MethodCallContext.new(text, target: match["target"].strip,
    method: match["method"],
    method_db: Scry::Completion::MethodDB.new)
end

module Scry::Completion
  describe MethodCallContext do
    it "#get_type" do
      context "it identifies booleans" do
        code = "
                    a = true
                    a‸meth
                "
        context = parse_example(code)

        context.get_type.should eq "Bool"

        code = "
                    a = false
                    a‸meth
                "
        context = parse_example(code)

        context.get_type.should eq "Bool"

        code = "
                    a =
                        false
                    a‸meth
                "
        context = parse_example(code)

        context.get_type.should eq "Bool"

        code = "
                    a = 1
                    a = true
                    a‸methd
                "

        context = parse_example(code)

        context.get_type.should eq("Bool")
      end
      context "it identifies numbers" do
        code = "
                    a = 1
                    a‸methd
                "
        context = parse_example(code)

        context.get_type.should eq("Int32")

        code = "
                    a =
                        1
                    a‸methd
                "
        context = parse_example(code)

        context.get_type.should eq("Int32")

        code = "
                    a = true
                    a = 1
                    a‸methd
                "

        context = parse_example(code)

        context.get_type.should eq("Int32")
      end

      context "it identifies regular objects" do
        code = "
                    abc = Abc.new
                    abc‸methd
                "
        context = parse_example(code)

        context.get_type.should eq("Abc")

        code = "
                    abc =
                        Abc.new
                    abc‸methd
                "
        context = parse_example(code)

        context.get_type.should eq("Abc")

        code = "
                    a = true
                    a = A.new
                    a‸methd
                "

        context = parse_example(code)

        context.get_type.should eq("A")

        code = "
                    a = true
                    a = A.new(1)
                    a‸methd
                "

        context = parse_example(code)

        context.get_type.should eq("A")

        context.get_type.should eq("A")

        code = "
                    a = true
                    a = A.new(true)
                    a‸methd
                "

        context = parse_example(code)

        context.get_type.should eq("A")
      end

      context "it identifies from method defintion" do
        code = "
                def blah(a : A)
                    a‸methd
                "
        context = parse_example(code)

        context.get_type.should eq("A")

        code = "
                def blah(a : A)
                end
                def blah_2(a : B)
                    a‸methd
                "
        context = parse_example(code)

        context.get_type.should eq("B")
      end

      context "it identifies from property defintion" do
        code = "
                property a : Blah
                def blah(a : A)
                    @a‸methd
                "
        context = parse_example(code)

        context.get_type.should eq("Blah")

        code = "
                getter a : Clah
                def blah(a : A)
                    @a‸methd
                "
        context = parse_example(code)

        context.get_type.should eq("Clah")

        code = "
                setter a : Dlah
                def blah(a : A)
                    @a‸methd
                "
        context = parse_example(code)

        context.get_type.should eq("Dlah")
      end

      context "it uses the closest type definition" do
        code = "
                def blah(a : A)
                end
                def blah_2(a : B)
                    a = 2
                    a‸methd
                "
        context = parse_example(code)

        context.get_type.should eq("Int32")

        code = "
                a = 2
                def blah_2(a : B)
                    a‸methd
                "
        context = parse_example(code)

        context.get_type.should eq("B")
      end

      context "it identifies class method calls" do
        code = "
                Abc‸methd
                "
        context = parse_example(code)

        context.get_type.should eq("Abc.class")
      end
    end
  end
end
