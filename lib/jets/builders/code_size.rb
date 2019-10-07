module Jets::Builders
  class CodeSize
    LAMBDA_SIZE_LIMIT = 250 # Total lambda limit is 250MB
    include Util

    def self.check!
      new.check
    end

    def check
      return if within_lambda_limit?
      say "Over the Lambda size limit of #{LAMBDA_SIZE_LIMIT}MB".color(:red)
      say "Please reduce the size of your code."
      display_sizes
      exit 1
    end

    def within_lambda_limit?
      total_size < LAMBDA_SIZE_LIMIT * 1024 # 120MB
    end

    def total_size
      code_size = compute_size("#{stage_area}/code")
      opt_size = compute_size("#{stage_area}/opt")
      opt_size + code_size # total_size
    end

    def display_sizes
      code_size = compute_size("#{stage_area}/code")
      opt_size = compute_size("#{stage_area}/opt")
      total_size = opt_size + code_size
      overlimit = (LAMBDA_SIZE_LIMIT * 1024 - total_size) * -1
      say "Sizes:"
      say "Code: #{megabytes(code_size)} - #{stage_area}/code"
      say "Gem Layer: #{megabytes(opt_size)} - #{stage_area}/opt"
      say "Total Package: #{megabytes(total_size)}"
      say "Over limit by: #{megabytes(overlimit)}"
      say "Sometimes blowing away the /tmp/jets cache will reduce the size: rm -rf /tmp/jets"
      # sh "du -kcsh #{stage_area}/*" unless Jets.env.test? # uncomment to debug
    end

    def compute_size(path)
      # -k option is required for macosx but not for linux
      out = `du -ks #{path}`
      out.split(' ').first.to_i # bytes
    end

    def megabytes(bytes)
      n = bytes / 1024.0
      sprintf('%.1f', n) + 'MB'
    end

    def say(message)
      puts message unless Jets.env.test?
    end
  end
end
