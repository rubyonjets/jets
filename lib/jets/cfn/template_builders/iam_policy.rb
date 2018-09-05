module Jets::Cfn::TemplateBuilders::IamPolicy
  autoload :ApplicationRole, "jets/cfn/template_builders/iam_policy/application_role"
  autoload :BasePolicy, "jets/cfn/template_builders/iam_policy/base_policy"
  autoload :ClassRole, "jets/cfn/template_builders/iam_policy/class_role"
  autoload :FunctionRole, "jets/cfn/template_builders/iam_policy/function_role"
end
