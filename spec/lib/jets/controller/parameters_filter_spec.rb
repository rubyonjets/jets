class ParametersFilterTest
  include Jets::Controller::Decorate::Logging
  attr_reader :parameter_filter
  def initialize(filter_values)
    @parameter_filter = ActiveSupport::ParameterFilter.new(filter_values)
  end
end

RSpec.describe "Jets::Controller::Decorate::Logging" do
  describe "#filter_json_log" do
    let(:result) do
      ParametersFilterTest.new(filtered_values).filter_json_log(json_text)
    end

    let(:json_text) do
      JSON.dump(
        password: "private_text",
        password_confirmation: 'private_text_wrong',
        name: 'Joe',
        bio: 'Ruby on jets!'
      )
    end

    context 'When filtered_parameters is not empty' do
      let(:filtered_values) { %i[password password_confirmation] }

      it 'Should return a new json with filtered_parameters masked as [FILTERED]' do
        expect(result).to eq("{\"password\":\"[FILTERED]\",\"password_confirmation\":\"[FILTERED]\",\"name\":\"Joe\",\"bio\":\"Ruby on jets!\"}")
      end
    end

    context 'When filtered_parameters is empty' do
      let(:filtered_values) { [] }

      it 'Should return the original json text' do
        expect(result).to eq(json_text)
      end
    end

    context 'When json_text has wrong format' do
      let(:filtered_values) { %i[password password_confirmation] }
      let(:json_text) { "just a text" }

      it 'Should return a [FILTERED]' do
        expect(result).to eq("[FILTERED]")
      end
    end
  end
end
