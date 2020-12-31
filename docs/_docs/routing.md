---
title: Routing
---

{% include routing.md %}


## Production Deployment

Important: If you are deploying a production service, it is strongly recommended to use a [Custom Domain]({% link _docs/routing/custom-domain.md %}). Jets computes and figures out whether or not it needs to replace the REST API as part of deployment. When the REST API is replaced, the API Endpoint will be different. By using Custom Domain, you'll be able to keep the same endpoint.

