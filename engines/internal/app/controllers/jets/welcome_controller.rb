# frozen_string_literal: true

class Jets::WelcomeController < Jets::ApplicationController # :nodoc:
  skip_forgery_protection
  layout false

  def index
  end
end
