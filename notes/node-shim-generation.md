LambdaDeducer
* node shims
* child template

build.rb: build_shims(deducer)

# 1. each LambdaDeducer
  def each_deducer
    controller_paths.each do |path|
      deducer = LambdaDeducer.new(path)
      yield(deducer)
    end
  end

  each_deducer do |deducer|
    puts "  #{deducer.path} => #{deducer.js_path}"
    generate_node_shim(deducer)
  end

# 2. generate_node_shim(deducer)
  def generate_node_shim(deducer)
    handler = Jets::Build::ControllerHandler.new(deducer.class_name, *deducer.functions)
    handler.generate
  end

# 3. handler.generate - this generate method does a lot of deductions right also

  @process_type = process_type
  @functions = @methods.map do |m|
    {
      name: m,
      handler: handler(m)
    }
  end
  result = ERB.new(template, nil, "-").result(binding)
