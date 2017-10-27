class Jets::Cfn::Diff < Jets::Cfn::Base
  include Jets::Cfn::AwsServices

  def run
    unless stack_exists?(@stack_name)
      puts "WARN: Cannot create a diff for the stack because the #{@stack_name} does not exists.".colorize(:yellow)
      return
    end

    if @options[:noop]
      puts "NOOP Generating CloudFormation source code diff..."
    else
      generate_all # from Base superclass. Generates the output lono teplates
      puts "Generating CloudFormation source code diff..."
      download_existing_cfn_template
      show_changes
    end
  end

  def download_existing_cfn_template
    resp = cfn.get_template(
      stack_name: @stack_name,
      template_stage: "Original"
    )
    resp.template_body
    IO.write(existing_template_path, resp.template_body)
  end

  def show_changes
    command = "#{diff_viewer} #{existing_template_path} #{new_cfn_template}"
    puts "Running: #{command}"
    system(command)
  end

  # for clarity
  def new_cfn_template
    @template_path
  end

  def diff_viewer
    return ENV['LONO_CFN_DIFF'] if ENV['LONO_CFN_DIFF']
    system("type colordiff > /dev/null") ? "colordiff" : "diff"
  end

  def existing_template_path
    "/tmp/existing_cfn_template.yml"
  end
end
