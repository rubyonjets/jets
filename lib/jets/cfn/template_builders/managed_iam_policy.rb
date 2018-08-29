module Jets::Cfn::TemplateBuilders::ManagedIamPolicy
  autoload :ApplicationPolicy, "jets/cfn/template_builders/managed_iam_policy/application_policy"
  autoload :BasePolicy, "jets/cfn/template_builders/managed_iam_policy/base_policy"
  autoload :ClassPolicy, "jets/cfn/template_builders/managed_iam_policy/class_policy"
  autoload :FunctionPolicy, "jets/cfn/template_builders/managed_iam_policy/function_policy"
end
