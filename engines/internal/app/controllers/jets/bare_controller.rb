# Parent class for MountController
class Jets::BareController < Jets::Controller::Base
  layout false
  abstract!
  skip_forgery_protection
end