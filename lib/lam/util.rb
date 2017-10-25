module Lam::Util
  # Ensures trailing slash
  # Useful for appending a './' in front of a path or leaving it alone.
  # Returns: '/path/with/trailing/slash/' or './'
  @@project_root = nil
  def project_root
    return @@project_root if @@project_root
    @@project_root = ENV['PROJECT_ROOT'].to_s
    @@project_root = '.' if @@project_root == ''
    @@project_root = "#{@@project_root}/" if @@project_root[-1] != '/'
    @@project_root
  end
end