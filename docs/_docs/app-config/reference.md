---
title: Config Reference
---

Here's a list of the available config settings.

Name | Description | Default
--- | --- | ---
project_name | Jets project name | generated as part of `jets new`
cors | Enable cors | false
autoload_paths | Customize autoload paths. Add extra paths you want to Jets autoload. | []
ignore_paths| Customize ignore paths. These paths will be ignored by the autoloader. | []
logger | Jets logger | `Jets::Logger.new($stderr)`
time_zone | Time zone | UTC
function.timeout | Lambda function default timeout | 30
function.memory_size | Lambda function default memory size | 1536
prewarm.enable | Enable prewarming noop call. | true
prewarm.rate | Prewarming Rate | 30 minutes
prewarm.concurrency | Prewarning concurrency | 2
prewarm.public_ratio | Prewarming public ratio | 3
prewarm.rack_ratio | Prewarming rack ratio | 5
gems.disable | Disable use of [Serverless Gems]({% link _docs/serverlessgems.md %}) service. Note, this means you must build a custom lambda layer yourself. | false
gems.source | Default gems source | https://api.serverlessgems.com/api/v1
gems.clean | Whether or not to always rebuild binary gems in the cache folder. | false
inflections.irregular | Special case inflections | {}
assets.folders | Folders to assets package and upload to s3 | %w[assets images packs]
assets.base_url | Base url to use to serve assets. IE: https://cloudfront.com/my/base/path. By default this is the s3 website url that jets manages. | nil
assets.max_age | Default max age on assets | 3600
assets.cache_control | The cache control expiry. IE: `public, max-age=3600`. Note, `assets.max_age` is a shorter way to set cache_control.  | nil
session.store | Session storage.  Note when accessing it use `session[:store]`` since ``.store` is an OrderedOptions method. | Rack::Session::Cookie
session.options | Session storage options | {}
api.auto_replace | Whether or not to auto replace the API Gateway when necessary. By default, will prompt user. Setting this to `true` bypasses the prompt. Note changing the API Gateway will change the endpoint. It's recommended to set up a [custom domain]({% link _docs/routing/custom-domain.md %}) which is updated with the new API Gateway endpoint automatically. | nil
api.authorization_type | API Gateway default authorization_type | NONE
api.cors_authorization_type | API Gateway default authorization_type for CORS. Note, default is `nil` so ApiGateway::Cors#cors_authorization_type handles. | nil
api.binary_media_types | Content types to treat as binary | ['multipart/form-data']
api.endpoint_type | Endpoint type. IE: PRIVATE, EDGE, REGIONAL | EDGE
api.endpoint_policy | Note, required when endpoint_type is EDGE | nil
api.api_key_required | Whether or not to require API key | false
api.authorizers.default_token_source | This the header to look for and use in the `method.request.header`. IE: `method.request.header.Auth` | Auth
domain.name | Custom domain name to use. Recommend to leave nil and jets will set a conventional custom domain name and then use CloudFront in front outside of Jets to fully control the domain name. | nil
domain.cert_arn | Cert ARN for SSL | nil
domain.endpoint_type | The endpoint type to create for API Gateway custom domain. IE: EDGE or REGIONAL. Default to EDGE because CloudFormation update is faster | REGIONAL
domain.route53 | Controls whether or not to create the managed route53 record. | true
lambda.layers | Additional custom lambda layers to use.  | []
encoding.default | Default encoding | utf-8
s3_event.configure_bucket | Whether or not to customer the bucket with the event notification trigger. | true
s3_event.notification_configuration | Notification configuration | nil
helpers.host | Override the host value use in the view helpers. IE: https://myurl.com:8888 | nil
controllers.default_protect_from_forgery | Whether or not to check for forgery protection | defaults to true for html and false for api mode.
controllers.filtered_parameters | Parameters to filter in logging output | []
app.domain | The app domain to use. Should be the domain only without the protocol. This applies at the controller-level, IE: methods like `redirect_to` | nil
deploy.stagger.enabled | Stagger the cloudformation update. Can be helpful with large apps. | false
deploy.stagger.batch_size  | Stagger the cloudformation update batch size. | 10
hot_reload | Whether or not to hot reload | Defaults to true in development and false in other envs

Here's also the [application/defaults.rb](https://github.com/boltops-tools/jets/blob/master/lib/jets/application/defaults.rb) source where these config options are defined.
