---
title: App Files
---

If you already have pre-existing files like zip files that need to be uploaded to s3, you can put them in `app/files`.  When the s3_folder option is configured in [settings.yml]({% link _docs/settings.md %}) the files in `app/files` automatically get uploaded as part of the `lono cfn` commands. The files get uploaded to `[S3_FOLDER]/[LONO_ENV]/app/files`. For example, given a file in `app/files/lambda-function.zip` and these settings:

```
development:
  s3_folder:
    default: s3://my-bucket/cloudformation
```

Example of how the file will upload to s3:

Local path | S3 path
--- | ---
app/files/lambda-function.zip | s3://my-bucket/cloudformation/development/files/lambda-function-0719ab81.zip

Notice the 0719ab81 is the md5 sum of the file.  This is added automatically beause it is useful if you are uploading the file to be used as a lambda function in a CloudFormation Lambda resource.  You can refer to the file with the `file_s3_key("lambda-function")` [built-in helper]({% link _docs/builtin-helpers.md %}).

<a id="prev" class="btn btn-basic" href="{% link _docs/app-scripts.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/builtin-helpers.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
