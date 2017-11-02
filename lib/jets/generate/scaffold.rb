# jets generate scaffold posts id:string title:string description:string
class Jets::Generate::Scaffold
  def initialize(options)
    @options = options
  end

  def run
    puts "Creating scaffold"
    return if @options[:noop]
    create_scaffold
  end

  def create_scaffold
    puts "TODO: implement create_scaffold"
  end
end
