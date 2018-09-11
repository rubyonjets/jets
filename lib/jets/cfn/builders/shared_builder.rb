class Jets::Cfn::Builders
  class SharedBuilder < BaseChildBuilder
    def compose
      add_shared_resources
    end

    def add_shared_resources
      puts "add_shared_resources".colorize(:cyan)
      puts "@app_klass: #{@app_klass.inspect}"
    end
  end
end
