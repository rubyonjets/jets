RSpec.describe Jets::Controller::ParametersFilter do
  describe "#filter_json" do
    let(:result) do
      described_class.new(filtered_values).filter_json(json_text)
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

      it 'Should return a blank string' do
        expect(result).to eq("")
      end
    end
  end
end
