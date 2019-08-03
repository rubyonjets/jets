# frozen_string_literal: true

class Admin::PagesController < ApplicationController
  def index
    render json: {"action": "index"}
  end
end
