# Example seed data for demo

def create_request(title)
  id = title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  {
    put_request: {
      item: {
        "id" => id,
        "title" => title,
        "created_at" => Time.now.utc.strftime('%Y-%m-%dT%TZ'),
        "updated_at" => Time.now.utc.strftime('%Y-%m-%dT%TZ'),
      }
    }
  }
end

require "jets"
Jets.boot
db = Post.db

requests = []
%w[tung vuon vanessa karissa alyssa].each do |name|
  request = create_request(name)
  requests << request
end
resp = db.batch_write_item(
  request_items: { # required
    Post.table_name => requests
  }
)

puts "Seed data for the posts table created."
