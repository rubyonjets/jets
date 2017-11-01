class Jets::New
  def initialize(project_name, options)
    @project_name = project_name
    @options = options
  end

  def run
    puts "Creating new project called #{@project_name}."
  end

end
