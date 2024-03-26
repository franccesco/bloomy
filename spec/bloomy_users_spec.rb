RSpec.describe Bloomy::UserOperations do
  let(:client) { Bloomy::Client.new }

  describe '#get_user_details' do
    context 'when direct_reports and positions are false' do
      it 'returns the basic user details' do
        user_details = client.get_user_details
        expect(user_details).to include(
          name: a_kind_of(String),
          id: a_kind_of(Integer),
          image_url: a_kind_of(String)
        )
        expect(user_details).not_to have_key(:direct_reports)
        expect(user_details).not_to have_key(:positions)
      end
    end

    context 'when direct_reports is true' do
      it 'returns the user details with direct reports' do
        user_details = client.get_user_details(direct_reports: true)
        expect(user_details).to include(
          name: a_kind_of(String),
          id: a_kind_of(Integer),
          image_url: a_kind_of(String),
          direct_reports: a_kind_of(Array)
        )
      end
    end

    context 'when positions is true' do
      it 'returns the user details with positions' do
        user_details = client.get_user_details(positions: true)
        expect(user_details).to include(
          name: a_kind_of(String),
          id: a_kind_of(Integer),
          image_url: a_kind_of(String),
          positions: a_kind_of(Array)
        )
      end
    end
  end

  describe '#get_direct_reports' do
    it 'returns the direct reports of the user' do
      direct_reports = client.get_direct_reports(client.get_my_user_id)
      expect(direct_reports).to all(include(
        name: a_kind_of(String),
        id: a_kind_of(Integer),
        image_url: a_kind_of(String)
      ))
    end
  end

  describe '#get_positions' do
    it 'returns the positions of the user' do
      positions = client.get_positions(client.get_my_user_id)
      expect(positions).to all(include(
        name: a_kind_of(String),
        id: a_kind_of(Integer)
      ))
    end
  end

  describe '#search_users' do
    it 'returns the users that match the search term' do
      users = client.search_users('fran')
      expect(users).to all(include(
        id: a_kind_of(Integer),
        name: a_kind_of(String),
        description: a_kind_of(String),
        email: a_kind_of(String),
        organization_id: a_kind_of(Integer),
        image_url: a_kind_of(String)
      ))
    end
  end
end
