RSpec.describe "User Operations" do
  let(:client) { Bloomy::Client.new }

  context "when interacting with the users API", :vcr do
    it "returns the main user's details" do
      user_details = client.get_user_details
          expect(user_details).to include(
            "Id" => a_kind_of(Integer),
            "Type" => a_kind_of(String),
            "Key" => a_kind_of(String),
            "Name" => a_kind_of(String),
            "ImageUrl" => a_kind_of(String)
          )
    end

    it "returns the main user's direct reports", :vcr do
      direct_reports = client.get_direct_reports
      expect(direct_reports).to include(
        {
          name: a_kind_of(String),
          id: a_kind_of(Integer)
        }
      )
    end
  end
end
