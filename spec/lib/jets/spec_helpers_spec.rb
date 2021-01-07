# frozen_string_literal: true

require "jets/spec_helpers"

class SimpleController < Jets::Controller::Base
  layout :application

  def index
    render json: {}
  end

  def show
    if params[:id] == '404'
      render json: {}, status: :not_found
    else
      render json: { id: params[:id], filter: params[:filter] }
    end
  end

  def create
    render json: { id: params[:id] }, status: :created
  end

  def update
    render json: { id: params[:id], name: params[:name] }
  end

  def destroy
    render json: {}, status: :no_content
  end
end

describe Jets::SpecHelpers do
  before do
    Jets.application.routes.draw do
      get 'spec_helper_test', to: 'simple#index'
      get 'ほげ', to: 'simple#index'

      get 'spec_helper_test/:id', to: 'simple#show'
      get 'ほげ/:id', to: 'simple#show'

      post 'spec_helper_test', to: 'simple#create'

      put 'spec_helper_test/:id', to: 'simple#update'

      delete 'spec_helper_test/:id', to: 'simple#destroy'
    end
  end

  context "get" do
    let(:nested_params) do
      {
        level_1: {
          level_2: {
            level_3: {

            }
          }
        }
      }.with_indifferent_access
    end

    it "gets 200" do
      get '/spec_helper_test'
      expect(response.status).to eq 200
    end

    it "gets 200 with id" do
      get '/spec_helper_test/:id', id: 123
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['id']).to eq '123'
    end

    it "gets 200 with unicode" do
      get '/ほげ'
      expect(response.status).to eq 200
    end

    it "gets 200 with id and unicode" do
      get '/ほげ/:id', id: 'ふが'
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['id']).to eq 'ふが'
    end

    it "gets 200 with query params" do
      get '/spec_helper_test/:id', id: 123, query: { filter: 'abc' }
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['filter']).to eq 'abc'
    end

    it "gets 200 with nested query params" do
      get '/spec_helper_test/:id', id: 123, query: { filter: nested_params }

      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['filter']).to eq nested_params
    end

    it "gets 200 with array query params" do
      get '/spec_helper_test/:id', id: 123, query: { filter: ['abc', 'def'] }
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['filter']).to eq ['abc', 'def']
    end

    it "gets 200 with query params with params keyword" do
      get '/spec_helper_test/:id', id: 123, params: { filter: 'abc' }
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['filter']).to eq 'abc'
    end

    it "gets 200 with unicode query params" do
      get '/spec_helper_test/:id', id: 123, query: { filter: 'ふが' }
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['filter']).to eq 'ふが'
    end

    it "gets 200 with query params no query keyword" do
      get '/spec_helper_test/:id', id: 123, filter: 'abc'
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['filter']).to eq 'abc'
    end

    it "gets 200 with route params" do
      get '/spec_helper_test/123'
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['id']).to eq '123'
    end

    it "gets 404 with id" do
      get '/spec_helper_test/:id', id: 404
      expect(response.status).to eq 404
    end
  end

  context "post" do
    it "posts 201" do
      post '/spec_helper_test', params: { id: 123 } # params also works
      expect(response.status).to eq 201
      expect(JSON.parse(response.body)['id']).to eq '123'
    end
  end

  context "put" do
    it "puts" do
      put '/spec_helper_test/:id', id: 1, name: 'Tom'
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['id']).to eq '1'
      expect(JSON.parse(response.body)['name']).to eq 'Tom'
    end
  end

  context "delete" do
    it "destroys" do
      delete '/spec_helper_test/:id', id: 1
      expect(response.status).to eq 204
    end
  end

  context "fixtures" do
    it "gets valid fixture path" do
      expect(fixture_path('abc')).to eq "#{Jets.root}/spec/fixtures/abc"
    end
  end
end
