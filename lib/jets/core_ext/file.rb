class File
  class << self
    # Ruby 3.2 removed File.exists?
    # aws_config/store.rb uses it
    # https://github.com/a2ikm/aws_config/blob/ef9cdd0eda116577f7d358bc421afd8e2f1eb1d3/lib/aws_config/store.rb#L6
    # Probably a bunch of other libraries still use File.exists? also
    alias_method :exists?, :exist?
  end
end
