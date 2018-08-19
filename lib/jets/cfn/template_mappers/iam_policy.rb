module Jets::Cfn::TemplateMappers::IamPolicy
  autoload :ApplicationPolicyMapper, "jets/cfn/template_mappers/iam_policy/application_policy_mapper"
  autoload :BasePolicyMapper, "jets/cfn/template_mappers/iam_policy/base_policy_mapper"
  autoload :ClassPolicyMapper, "jets/cfn/template_mappers/iam_policy/class_policy_mapper"
  autoload :FunctionPolicyMapper, "jets/cfn/template_mappers/iam_policy/function_policy_mapper"
end
