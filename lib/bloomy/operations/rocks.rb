module Bloomy
  module RockOperations
    include Bloomy::UserOperations
    def get_rocks(user_id: get_my_user_id)
      response = @conn.get("rocks/user/#{user_id}").body
      response.map do |rock|
        {
          id: rock['Id'],
          title: rock['Name'],
          created_at: rock['CreateTime'],
          due_date: rock['DueDate'],
          status: rock['Complete'] ? 'Completed' : 'Incomplete'
        }
      end
    end

    def get_archived_rocks(user_id: get_my_user_id)
      response = @conn.get("archivedrocks/user/#{user_id}").body
      response.map do |rock|
        {
          id: rock['Id'],
          title: rock['Name'],
          created_at: rock['CreateTime'],
          due_date: rock['DueDate'],
          status: rock['Complete'] ? 'Completed' : 'Incomplete'
        }
      end
    end
  end
end
