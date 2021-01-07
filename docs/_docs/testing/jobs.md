---
title: Job Spec
---

Let's say you have a HardJob class:

```ruby
class HardJob < ApplicationJob
  rate "10 hours" # every 10 hours
  def dig
    {done: "digging"}
  end
end
```

## Example 1

Here's a simple example of a job spec.

spec/job/hard_job_spec.rb:

```ruby
describe HardJob, type: :job do
  let(:event) { {} }
  it "dig" do
    result = HardJob.perform_now(:dig, event)
    expect(result).to eq(done: "digging")
  end
end
```

## Example 2

If you need to mock out instance methods in your job class, you may want to use something like this:

```ruby
describe HardJob, type: :job do
  let(:job) { HardJob.new(event, context, :dig) }
  let(:event) { {} }
  let(:context) { {} }

  it "dig" do
    allow(job).to receive(:some_method) # Example of stub
    result = job.dig
    expect(result).to eq(done: "digging")
  end
end
```

