---
title: MFA
nav_order: 89
---

## Deploying with MFA

Jets supports the use of Multi Factor Authentication using AWS environment variables.

Using a secure note in your favorite password manager, you can present environment variables for your jets commands.

Here is an example of a secure note template that ends with a `jets deploy`:
```bash
stty -echo
set +o history
unset AWS_SESSION_TOKEN AWS_MFA_SERIAL AWS_SECURE_TOKEN
export AWS_ACCESS_KEY_ID=<aws access key id>
export AWS_SECRET_ACCESS_KEY=<aws secrect>
export AWS_REGION=<aws region>
export AWS_ACCOUNT_ID=<aws account id>
export USER=<aws username>
stty echo

export AWS_MFA_SERIAL=<aws mfa arn> AWS_SECURE_TOKEN='' && clear && echo && read -p "Enter the MFA code for the ${USER} user on the ${AWS_ACCOUNT_ID} Account: " AWS_MFA_TOKEN && export AWS_MFA_TOKEN=${AWS_MFA_TOKEN} && set -o history && jets deploy

```
Once a template like this is setup, you can paste the content into a terminal that will then will prompt you for the MFA token:
```
Enter the MFA code for the admin user on the 12345678901 Account:
```
You can then enter an MFA token and press enter and the `jets deploy` will proceed as usual.

### Assuming a Role
You can also `export AWS_ROLE_ARN=<aws role arn>` to assume a role with MFA.

{% include prev_next.md %}
