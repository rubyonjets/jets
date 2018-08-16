---
title: Development Speed
---

Development speed with AWS Lambda can be slown down due to having to upload the Ruby interpreter and gems as part of the deployment package. The recommendation for this is to use [Cloud9](https://aws.amazon.com/cloud9/). This is what I've done in order to avoid the slow upload. Since Cloud9 runs on an EC2 instance, we get to take advantage of the fast internet pipe. 

EC2 Instance Internet Speed:

    $ curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -
    Testing download speed...................................................................
    Download: 443.69 Mbit/s
    Testing upload speed.......................................................................
    Upload: 438.73 Mbit/s
    $ 
    

Typical Home Internet Speed:

    $ curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -
    Testing download speed...................................................................
    Download: 100.50 Mbit/s
    Testing upload speed......................................................................
    Upload: 6.78 Mbit/s
    $

There's no comparision. It's the upload speed that destroys productivity. I've actually come to enjoy using Cloud9 and have been pretty happy with it.

Another approach for a team is to set up a CI/CD pipeline that will deploy when git commits are pushed.

Would like to improve the speed of the deploying these large packages though and would love to try some ideas for this in the future.

<a id="prev" class="btn btn-basic" href="{% link _docs/surfacing-ruby-errors.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/database-support.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
