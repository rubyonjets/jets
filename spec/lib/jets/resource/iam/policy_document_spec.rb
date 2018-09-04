describe Jets::Resource::Iam::PolicyDocument do
  let(:document) do
    Jets::Resource::Iam::PolicyDocument.new(definitions)
  end

  # Most of the specs around IamPolicy is in function_policy_spec.rb.
  # Writing a spec here as a sanity check.
  context "single string" do
    let(:definitions) { "logs:*" }
    it "builds the resource definition" do
      iam_policy_document = <<~EOL
        Version: '2012-10-17'
        Statement:
        - Sid: Stmt1
          Action:
          - logs:*
          Effect: Allow
          Resource: "*"
      EOL
      expected_policy = YAML.load(iam_policy_document)
      expect(document.policy_document).to eq expected_policy
    end
  end

  context "array with single string" do
    let(:definitions) { ["logs:*"] }
    it "builds the resource definition" do
      iam_policy_document = <<~EOL
        Version: '2012-10-17'
        Statement:
        - Sid: Stmt1
          Action:
          - logs:*
          Effect: Allow
          Resource: "*"
      EOL
      expected_policy = YAML.load(iam_policy_document)
      expect(document.policy_document).to eq expected_policy
    end
  end

  context "multiple strings" do
    let(:definitions) { ["ec2:*", "logs:*"] }
    it "provides the resource definition" do
      iam_policy_document = <<~EOL
        Version: '2012-10-17'
        Statement:
        - Sid: Stmt1
          Action:
          - ec2:*
          Effect: Allow
          Resource: "*"
        - Sid: Stmt2
          Action:
          - logs:*
          Effect: Allow
          Resource: "*"
      EOL
      expected_policy_document = YAML.load(iam_policy_document)
      expect(document.policy_document).to eq expected_policy_document
    end
  end

  context "single hash" do
    context "string keys" do
      let(:definitions) do
        [{
          "Sid" => "MyStmt1",
          "Action" => ["lambda:*"],
          "Effect" => "Allow",
          "Resource" => "arn:my-arn",
        }]
      end
      it "provides the resource definition" do
        iam_policy_document = <<~EOL
          Version: '2012-10-17'
          Statement:
          - Sid: MyStmt1
            Action:
            - lambda:*
            Effect: Allow
            Resource: arn:my-arn
        EOL
        expected_policy_document = YAML.load(iam_policy_document)
        expect(document.policy_document).to eq expected_policy_document
      end
    end

    context "symbol keys" do
      let(:definitions) do
        [{
          Sid: "MyStmt1",
          Action: ["lambda:*"],
          Effect: "Allow",
          Resource: "arn:my-arn",
        }]
      end
      it "provides the resource definition" do
        iam_policy_document = <<~EOL
          Version: '2012-10-17'
          Statement:
          - Sid: MyStmt1
            Action:
            - lambda:*
            Effect: Allow
            Resource: arn:my-arn
        EOL
        expected_policy_document = YAML.load(iam_policy_document)
        expect(document.policy_document).to eq expected_policy_document
      end
    end

    context "symbol keys with lowercase" do
      let(:definitions) do
        [{
          sid: "MyStmt1",
          action: ["lambda:*"],
          effect: "Allow",
          resource: "arn:my-arn",
        }]
      end
      it "provides the resource definition" do
        iam_policy_document = <<~EOL
          Version: '2012-10-17'
          Statement:
          - Sid: MyStmt1
            Action:
            - lambda:*
            Effect: Allow
            Resource: arn:my-arn
        EOL
        expected_policy_document = YAML.load(iam_policy_document)
        expect(document.policy_document).to eq expected_policy_document
      end
    end
  end

  context "multiple hashes" do
    context "symbol keys" do
      let(:definitions) do
        [{
          Sid: "MyStmt1",
          Action: ["lambda:*"],
          Effect: "Allow",
          Resource: "arn:my-arn",
        },{
          Sid: "MyStmt2",
          Action: ["logs:*"],
          Effect: "Allow",
          Resource: "*",
        }]
      end
      it "provides the resource definition" do
        iam_policy_document = <<~EOL
          Version: '2012-10-17'
          Statement:
          - Sid: MyStmt1
            Action:
            - lambda:*
            Effect: Allow
            Resource: arn:my-arn
          - Sid: MyStmt2
            Action:
            - logs:*
            Effect: Allow
            Resource: "*"
        EOL
        expected_policy_document = YAML.load(iam_policy_document)
        expect(document.policy_document).to eq expected_policy_document
      end
    end
  end


  context "special case hash with Version key" do
    context "symbol keys" do
      let(:definitions) do
        [{
          Version: "2012-10-17", # special case, a Version key will replace the entire policy
                                 # assumes that only one policy is passed in
          Statement: [{
            Sid: "MyStmt1",
            Action: ["lambda:*"],
            Effect: "Allow",
            Resource: "arn:my-arn",
          }]
        }]
      end
      it "provides the resource definition" do
        iam_policy_document = <<~EOL
          Version: '2012-10-17'
          Statement:
          - Sid: MyStmt1
            Action:
            - lambda:*
            Effect: Allow
            Resource: arn:my-arn
        EOL
        expected_policy_document = YAML.load(iam_policy_document)
        expect(document.policy_document).to eq expected_policy_document
      end
    end
  end
end
