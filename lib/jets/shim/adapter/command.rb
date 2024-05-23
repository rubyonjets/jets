require "open3"

module Jets::Shim::Adapter
  class Command < Base
    def handle
      cmd = event[:command]
      result = {stdout: "", stderr: ""}
      # splat works for both String and Array
      Open3.popen3(*cmd) do |stdin, stdout, stderr, wait_thread|
        result[:stdout] << stdout.read
        result[:stderr] << stderr.read
        result[:status] = wait_thread.value.exitstatus
      end
      result
    end

    def handle?
      event[:command]
    end
  end
end
