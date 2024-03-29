# frozen_string_literal: true

module Jets::Command::CredentialsCommand::Diffing # :nodoc:
  GITATTRIBUTES_ENTRY = <<~END
    config/credentials/*.yml.enc diff=jets_credentials
    config/credentials.yml.enc diff=jets_credentials
  END

  def enroll_project_in_credentials_diffing
    if enrolled_in_credentials_diffing?
      say "Project is already enrolled in credentials file diffing."
    else
      gitattributes.write(GITATTRIBUTES_ENTRY, mode: "a")

      say "Enrolled project in credentials file diffing!"
      say "Jets ensures the jets_credentials diff driver is set when running `credentials:edit`. See `credentials:help` for more."
    end
  end

  def disenroll_project_from_credentials_diffing
    if enrolled_in_credentials_diffing?
      gitattributes.write(gitattributes.read.gsub(GITATTRIBUTES_ENTRY, ""))
      gitattributes.delete if gitattributes.empty?

      say "Disenrolled project from credentials file diffing!"
    else
      say "Project is not enrolled in credentials file diffing."
    end
  end

  def ensure_diffing_driver_is_configured
    configure_diffing_driver if enrolled_in_credentials_diffing? && !diffing_driver_configured?
  end

  private
    def enrolled_in_credentials_diffing?
      gitattributes.file? && gitattributes.read.include?(GITATTRIBUTES_ENTRY)
    end

    def diffing_driver_configured?
      system "git config --get diff.jets_credentials.textconv", out: File::NULL
    end

    def configure_diffing_driver
      system "git config diff.jets_credentials.textconv 'bin/jets credentials:diff'"
    end

    def gitattributes
      Jets.root.join(".gitattributes")
    end
end
