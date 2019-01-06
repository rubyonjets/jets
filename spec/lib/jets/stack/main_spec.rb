class AllInOne < Jets::Stack
  cloudwatch_alarm(:billing_alarm,
    depends_on: logical_id(:billing_notification),
    properties: {
      alarm_description: "Alarm if AWS spending is too much",
      namespace: "AWS/Billing",
      metric_name: "EstimatedCharges",
      dimensions: [{name: "Currency", value: "USD"}],
      statistic: "Maximum",
      period: "21600",
      evaluation_periods: "1",
      threshold: 100,
      comparison_operator: "GreaterThanThreshold",
      alarm_actions: ["!Ref BillingNotification"],
    }
  )
  sns_topic(:billing_notification)
end

describe "Stack templates" do
  let(:stack) { AllInOne.new }
  it "outputs" do
    templates = stack.outputs.map(&:template)
    expect(templates).to eq(
      [{"BillingAlarm"=>{"Value"=>"!Ref BillingAlarm"}},
       {"BillingNotification"=>{"Value"=>"!Ref BillingNotification"}}]
    )
  end

  it "resources" do
    templates = stack.resources.map(&:template)
    expect(templates).to eq(
      [{"BillingAlarm"=>
         {"DependsOn"=>"BillingNotification",
          "Properties"=>
           {"AlarmDescription"=>"Alarm if AWS spending is too much",
            "Namespace"=>"AWS/Billing",
            "MetricName"=>"EstimatedCharges",
            "Dimensions"=>[{"Name"=>"Currency", "Value"=>"USD"}],
            "Statistic"=>"Maximum",
            "Period"=>"21600",
            "EvaluationPeriods"=>"1",
            "Threshold"=>100,
            "ComparisonOperator"=>"GreaterThanThreshold",
            "AlarmActions"=>["!Ref BillingNotification"]},
          "Type"=>"AWS::CloudWatch::Alarm"}},
       {"BillingNotification"=>{"Type"=>"AWS::SNS::Topic"}}]
    )
  end
end
