class Jets::Dotenv
  class Show
    def self.list
      puts "# Env from evaluated dotenv files"
      vars = Jets::Dotenv.load!
      vars.each do |k,v|
        puts "#{k}=#{v}"
      end
    end
  end
end
