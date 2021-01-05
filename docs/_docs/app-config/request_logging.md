---
title: Request Logging
---

By default, all params and event payload will be logged to CloudWatch in every request along with a completion log with the status code and duration of the request. You can over-ride each of these logs via the following:

lambda request started:

```ruby
class ApplicationController < Jets::Controller::Base
  def log_start
    Jets.logger.info "Lambda function begin"
  end
end
```

Lambda request completed:

This function accepts a options parameter. The `options` value is a Hash with these keys:

* status: status code of the web request (ie. 200)
* took: web request's execution time.

```ruby
class ApplicationController < Jets::Controller::Base
  def log_finish(options={})
    status, took = options[:status], options[:took]
    Jets.logger.info "Web request complete, status code: #{status}, took: #{took}s"
  end
end
```

{% include prev_next.md %}