# If the total number of scanned items exceeds the maximum data set size limit of 1 MB, the scan stops and results are returned to the user as a LastEvaluatedKey value to continue the scan in a subsequent operation.

# aws dynamodb get-item \
#     --table-name ProductCatalog \
#     --key file://key.json \
#     --projection-expression "Description, RelatedItems[0], ProductReviews.FiveStar"
#
# `key.json`:
# {
#     "Id": { "N": "123" }
# }



Scan params examples:
```ruby
      params = {
        expression_attribute_names: {
          "T" => "title",
          "D" => "desc",
        },
        expression_attribute_values: {
          ":a" => {
            s: "my title",
          },
        },
        filter_expression: "title = :a",
        projection_expression: "#T, #D",
        table_name: table_name,
      }

      params = {
        table_name: table_name,
        projection_expression: "title",
      }

      params = {
        table_name: table_name,
        expression_attribute_names: {"#t"=>"title", "#d"=>"desc"},
        projection_expression: "#t, #d",
      }

      params = {
        table_name: table_name,
        # desc is a keyword
        # since we can run into keywords we should always map attribute names
        # and values
        expression_attribute_values: {
          ":desc" => "my desc"
        },
        expression_attribute_names: {"#desc"=>"desc"},
        filter_expression: "#desc = :desc",
      }

      params = {
        table_name: table_name,
        filter_expression: "updated_at between :start_time and :end_time",
        expression_attribute_values: {
          ":start_time" => "2010-01-01T00:00:00",
          ":end_time" => "2020-01-01T00:00:00"
        }
      }

      params = {
        table_name: table_name,
        # projection_expression: "#t, #d",
        expression_attribute_names: {"#updated_at"=>"updated_at"},
        filter_expression: "#updated_at between :start_time and :end_time",
        expression_attribute_values: {
          ":start_time" => "2010-01-01T00:00:00",
          ":end_time" => "2020-01-01T00:00:00"
        }
      }

      Jets.logger.info("BaseModel Jets.env #{Jets.env.inspect}")
      Jets.logger.info("BaseModel params #{params.inspect}")

```
