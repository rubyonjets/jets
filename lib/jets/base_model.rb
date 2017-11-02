module Jets
  class BaseModel
    def db
      @db ||= Aws::DynamoDB::Client.new
    end
  end
end
