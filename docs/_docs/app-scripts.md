---
title: App Scripts
---

Often it is useful to be able to upload custom scripts to the server and run them. One way to do this is first to upload the scripts to s3 and then download them down to the server as part of the user-data script.  Lono supports this deployment flow with the `app/scripts` folder.

Any scripts added to the `app/scripts` folder get tarballed up and uploaded to s3. The s3 location is configured with the `s3_folder` option in [settings.yml]({% link _docs/settings.md %}) file.  Once the s3_folder option is configured `lono cfn create` and `lono cfn update` commands will automatically upload the `app/scripts` folder as part of generating templates.

## extract_scripts helper

Lono provides a [extract_scripts]({% link _docs/builtin-helpers.md %}) helper that you can include your `user_data` scripts to extract the `app/scripts` files in your lono project to `/opt/scripts` on the server.  Here's an example:

`app/user_data/bootstrap.sh`:

```
#!/bin/bash -exu

<%= extract_scripts(to: "/opt") %>

SCRIPTS=/opt/scripts
$SCRIPTS/install_stuff.sh
```

In order to use extract_scripts, you'll need scripts in the `app/scripts` folder. We'll add a test script:

```sh
cat >app/scripts/install_stuff.sh <<EOL
yum install -y jq
EOL
```

And remember to configure `s3_folder` in settings.yml. Example:

```
base:
  s3_folder: mybucket/path/to/folder # just an example
```

## lono user_data command

Typically, the `app/user_data` scripts are embedded in your CloudFormation templates with the `user_data` helper method.  You can see the generated script with `lono generate` and looking at the template in the `output/templates` folder.

The `lono user_data` command is also provided so you can see the code that `extract_script` helper produces.

Here's an example:

```sh
$ lono user_data bootstrap
Detected app/scripts
Tarballing app/scripts folder to scripts.tgz
=> cd app && dot_clean .
=> cd app && tar -c scripts | gzip -n > scripts.tgz
Tarball created at output/scripts/scripts-93b8b29b.tgz
Generating user_data for 'bootstrap' at ./app/user_data/bootstrap.sh
#!/bin/bash -exu

# Generated from the lono extract_scripts helper.
# Downloads scripts from s3, extract them, and setup.
mkdir -p /opt
aws s3 cp s3://mybucket/path/to/folder/development/scripts/scripts-93b8b29b.tgz /opt/
cd /opt
tar zxf /opt/scripts-93b8b29b.tgz
chmod -R a+x /opt/scripts
chown -R ec2-user:ec2-user /opt/scripts

SCRIPTS=/opt/scripts
$SCRIPTS/install_stuff.sh
$
```

## MD5 Checksum

Notice, that the name of the scripts tarball includes an md5 checksum.  Lono first generates a `scripts.tgz`, computes the file's md5sum and then renames it to include the md5sum.  There's a very good reason for this.

Whenever you make changes in your `app/scripts` folder and update your CloudFormation templates, CloudFormation does not see the changes.  If the same `scripts.tgz` s3 url were used then CloudFormation would not know that it needed to update the EC2 instance that uses the user-data script.  By including the md5 checksum in the file name, this changes the user-data script, and  this lets CloudFormation know that the scripts have changed.

<a id="prev" class="btn btn-basic" href="{% link _docs/layering.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/app-files.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
