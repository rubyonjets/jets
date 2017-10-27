class Jets::Cfn::Help
  class << self
    def create
<<-EOL
Examples:

Provided that you are in a lono project and have a `my-stack` lono template definition.  To create a stack you can simply run:

$ lono cfn create my-stack

The above command will generate and use the template in output/my-stack.json and parameters in params/my-stack.txt.  The template by convention defaults to the name of the stack.  In turn, the params by convention defaults to the name of the template.

Here are examples of overriding the template and params name conventions.

$ lono cfn create my-stack --template different1

The template used is output/different1.json and the parameters used is output/params/prod/different1.json.

$ lono cfn create my-stack --params different2

The template used is output/my-stack.json and the parameters used is output/params/prod/different2.json.

$ lono cfn create my-stack --template different3 --params different4

The template used is output/different3.json and the parameters used is output/params/prod/different4.json.

EOL
    end

    def update
<<-EOL
Examples:

Provided that you are in a lono project and have a `my-stack` lono template definition.  To update a stack you can simply run:

$ lono cfn update my-stack

The above command will generate and use the template in output/my-stack.json and parameters in params/my-stack.txt.  The template by convention defaults to the name of the stack.  In turn, the params by convention defaults to the name of the template.

Here are examples of overriding the template and params name conventions.

$ lono cfn update my-stack --template different1

The template used is output/different1.json and the parameters used is output/params/prod/different1.json.

$ lono cfn update my-stack --params different2

The template used is output/my-stack.json and the parameters used is output/params/prod/different2.json.

$ lono cfn update my-stack --template different3 --params different4

The template used is output/different3.json and the parameters used is output/params/prod/different4.json.

EOL
    end

    def delete
<<-EOL
Examples:

$ lono cfn delete my-stack

The above command will delete my-stack.
EOL
    end

    def preview
<<-EOL
Generates a CloudFormation preview.  This is similar to a `terraform plan` or puppet's dry-run mode.

Example output:

CloudFormation preview for 'example' stack update. Changes:

Remove AWS::Route53::RecordSet: DnsRecord testsubdomain.sub.tongueroo.com

Examples:

$ lono cfn preview my-stack
EOL
    end

    def diff
<<-EOL
Displays code diff of the generated CloudFormation template locally vs the existing template on AWS. You can set a desired diff viewer by setting the LONO_CFN_DIFF environment variable.

Examples:

$ lono cfn diff my-stack
EOL
    end

    def download
<<-EOL
Download CloudFormation template from existing template on AWS.

Examples:

$ lono cfn download my-stack
EOL
    end
  end
end
