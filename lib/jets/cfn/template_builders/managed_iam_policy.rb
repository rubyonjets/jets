module Jets::Cfn::TemplateBuilders::ManagedIamPolicy
  autoload :ApplicationRole, "jets/cfn/template_builders/managed_iam_policy/application_role"
  autoload :BasePolicy, "jets/cfn/template_builders/managed_iam_policy/base_policy"
  autoload :ClassRole, "jets/cfn/template_builders/managed_iam_policy/class_role"
  autoload :FunctionRole, "jets/cfn/template_builders/managed_iam_policy/function_role"
end
