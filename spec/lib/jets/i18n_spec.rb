describe "i18n" do
  describe "default locale" do
    it "is english" do
      expect(I18n.default_locale).to eq(:en)
    end
  end
end
