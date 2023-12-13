module Jets::Event::Helpers
  module S3Event
    extend Memoist

    def s3_events
      encoded_messages = event[:Records].map do |record|
        record[:Sns][:Message] # SNS message is JSON
      end
      # Decode the JSON messages
      messages = encoded_messages.map do |message|
        data = JSON.load(message)
        ActiveSupport::HashWithIndifferentAccess.new(data)
      end
      # Extract the S3 event records
      messages.map do |message|
        message[:Records].map do |record|
          ActiveSupport::HashWithIndifferentAccess.new(record)
        end
      end.flatten
    end

    def s3_events?
      event[:Records]&.any? { |r| r.dig(:Sns, :Message) }
    end

    def s3_objects
      s3_events.map do |record|
        record[:s3][:object]
      end
    end

    def s3_objects?
      s3_events.any? { |r| r.dig(:s3, :object) }
    end

    # Downloads the s3 object and returns a Ruby File-like handle to the object
    def s3_files
      s3_events.map do |event|
        bucket = event[:s3][:bucket][:name]
        object_key = event[:s3][:object][:key]

        s3 = Aws::S3::Resource.new
        obj = s3.bucket(bucket).object(object_key)

        file_path = "/tmp/s3_files/#{object_key}"
        FileUtils.mkdir_p(File.dirname(file_path))
        File.open(file_path, "w") do |file|
          obj.get(response_target: file)
        end

        file = File.open(file_path, "r")
        NamedFile.new(file, object_key)
      end
    end
    memoize :s3_files

    # The Ruby File handle does not store information about the filename.
    # NamedFile includes the filename which is useful for downstream processing.
    class NamedFile < ::File
      extend Memoist
      attr_reader :filename
      alias_method :object_key, :filename
      alias_method :key, :object_key

      def initialize(file_handle, filename)
        @filename = filename
        super(file_handle, "r")
      end

      def content
        read
      end
      memoize :content
    end
  end
end
