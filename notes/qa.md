## QA

Testing controller processing without node shim.

```
jets process controller '{ "we" : "love", "using" : "Lambda" }' '{"test": "1"}' "handlers/controllers/posts.create"
```

Testing the generated node shim handler and the controller processing.

```
cd spec/fixtures/project
jets build # generates the handlers
node handlers/controllers/posts.js
```

## API Gateway

Using lambda proxy Integration Request to connect to API Gateway changes the simply payload to a more complicated one with "body"

```
jets process controller '{"we":"love", "using":"Lambda"}' '{"test": "1"}' "handlers/controllers/posts.create"
```

Testing the generated node shim handler and the controller processing.

```
cd spec/fixtures/project
jets build # generates the handlers
node handlers/controllers/posts.js
```

Test CloudFormation commands
```sh
aws cloudformation create-stack --stack-name test-stack-$(date +%s) --template-body file://lib/jets/cfn/builder/templates/base-stack.yml --capabilities CAPABILITY_NAMED_IAM