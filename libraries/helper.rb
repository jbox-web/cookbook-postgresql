class ChefPostgresqlCookbook
  module Helper

    def self.user_exists?(db_user)
      require 'pg'
      c = ::PG.connect(user: 'postgres', dbname: 'postgres')
      r = c.exec("SELECT COUNT(*) FROM pg_user WHERE usename='#{db_user}'")
      r.entries[0]['count'] != '0'
    end

    def self.db_exists?(db_name)
      require 'pg'
      c = ::PG.connect(user: 'postgres', dbname: 'postgres')
      r = c.exec("SELECT COUNT(*) FROM pg_database WHERE datname='#{db_name}'")
      r.entries[0]['count'] != '0'
    end

  end
end
