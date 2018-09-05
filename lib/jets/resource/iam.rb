module Jets::Resource::Iam
  autoload :BaseRoleDefinition, 'jets/resource/iam/base_role_definition'
  autoload :ApplicationRole, 'jets/resource/iam/application_role'
  autoload :ClassRole, 'jets/resource/iam/class_role'
  autoload :FunctionRole, 'jets/resource/iam/function_role'
  autoload :PolicyDocument, 'jets/resource/iam/policy_document'
  autoload :ManagedPolicy, 'jets/resource/iam/managed_policy'
end