class Fib
    def self.execute(n)
        n.upto(1).reduce(1){|a,b| a * b}
    end
end