module Jets
  class Dir < ::Dir
    def self.glob(*args)
      # raise "hell"
      puts "Jets Dir called: #{caller[0]}"
      super
    end
  end
end