module Bloomy
  module RockOperations
    def get_my_rocks
      response = @conn.get('rocks/user/mine').body
      rocks = response.map do |rock|
        {
          id: rock['Id'],
          title: rock['Name'],
          created_at: rock['CreateTime'],
          due_date: rock['DueDate'],
          status: rock['Complete'] ? 'Completed' : 'Incomplete'
        }
      end
    end

    def get_my_archived_rocks
      response = @conn.get('archivedrocks/user/mine').body
      rocks = response.map do |rock|
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
