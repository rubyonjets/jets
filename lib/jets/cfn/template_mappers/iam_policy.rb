module Jets::Cfn::TemplateMappers::IamPolicy
  autoload :ApplicationRoleMapper, "jets/cfn/template_mappers/iam_policy/application_role_mapper"
  autoload :BasePolicyMapper, "jets/cfn/template_mappers/iam_policy/base_policy_mapper"
  autoload :ClassRoleMapper, "jets/cfn/template_mappers/iam_policy/class_role_mapper"
  autoload :FunctionRoleMapper, "jets/cfn/template_mappers/iam_policy/function_role_mapper"
end
