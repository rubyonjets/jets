github_url("https://github.com/tongueroo/jets.git")
linux_image("aws/codebuild/ruby:2.5.3-1.7.0")
triggers(
  webhook: true,
  filter_groups: [[{type: "HEAD_REF", pattern: "master"}, {type: "EVENT", pattern: "PUSH"}]]
)
environment_variables(
  SSH_KEY_S3_PATH: "ssm:/codebuild/jets/ssh_key_s3_path"
)
local_cache(true)