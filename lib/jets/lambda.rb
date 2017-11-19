# Task vs Function
#
# Function is inherited by Job::Base and Controller::Base.
# It is holds the event and context is used for processing when you
# call the lambda function.
#
# Task is a holds information for the method that gets registered
# with method_add and is used to build up the CloudFormation Lambda
# Function definition.
#
# Overview diagram : http://bit.ly/2zQeoF3
module Jets::Lambda
  autoload :Dsl, "jets/lambda/dsl"
  autoload :Function, "jets/lambda/function"
  autoload :Task, "jets/lambda/task"
end
