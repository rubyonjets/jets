class Jets::New
  autoload :Generator, "jets/new/generator"

  def initialize(project_name, options)
    @project_name = project_name
    @options = options
  end

  def run
    puts "Creating new project called #{@project_name}."
    generator = Generator.new(@project_name, @options)
    generator.run
  end
end
