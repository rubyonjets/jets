module Jets::Cfn::TemplateBuilders::IamPolicy
  autoload :BasePolicy, "jets/cfn/template_builders/iam_policy/base_policy"
  autoload :ClassPolicy, "jets/cfn/template_builders/iam_policy/class_policy"
  autoload :FunctionPolicy, "jets/cfn/template_builders/iam_policy/function_policy"
end
