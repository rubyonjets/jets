---
title: "Minimal Deploy IAM Policy: Console"
---

You can also create policy, group, and user in AWS console.  Note, refer to the [CLI Instructions]({% link _docs/extras/minimal-deploy-iam/cli.md %}) for IAM policy examples.

Go to [IAM Policies](https://console.aws.amazon.com/iam/home?nc2=h_m_sc#/policies).

1. Click "Create policy", then "JSON", then "Next: tags", then "Next: review".
2. Name the policy "JetsPolicy" and click "Create policy".

Go to [IAM Groups](https://console.aws.amazon.com/iam/home?nc2=h_m_sc#/groups).

1. Click "Create new group". Name the group "Jets" and click "Next step".
2. Search for "JetsPolicy", check its checkbox, click "Next step", then "Create group".

Go to [IAM Users](https://console.aws.amazon.com/iam/home?nc2=h_m_sc#/users).

1. Click "Add user". Give the user a name and check "Programmatic access".
2. Click "Next: permissions". Check the "Jets" group to add user to group.
3. Click "Next: tags", "Next: Review", then "Create user".
