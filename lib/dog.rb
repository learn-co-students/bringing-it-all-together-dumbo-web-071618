class Dog
    attr_accessor :id, :name, :breed

    def initialize(id: nil, name: , breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql= <<-SQL
            CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql= <<-SQL
            DROP TABLE dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            sql= <<-SQL
                INSERT INTO dogs(name, breed) VALUES(?, ?)
            SQL

            DB[:conn].execute(sql, @name, @breed)
            @id = DB[:conn].execute("SELECT id FROM dogs ORDER BY id DESC LIMIT 1").flatten[0]
            self
        end
    end

    def self.create(name:, breed:)
        Dog.new(name:name, breed:breed).save
    end

    def self.find_by_id(id)
        sql= <<-SQL
            SELECT * FROM dogs WHERE id = ?
        SQL
        row = DB[:conn].execute(sql, id).flatten
        Dog.new(id:row[0], name:row[1], breed:row[2])
    end

    def self.find_by_name(name)
        sql= <<-SQL
            SELECT * FROM dogs WHERE name = ?
        SQL
        row = DB[:conn].execute(sql, name).flatten
        Dog.new(id:row[0], name:row[1], breed:row[2])
    end

    def self.find_or_create_by(name:, breed:)
        search_result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1", name, breed).flatten
        if search_result.empty?
            Dog.create(name:name, breed:breed)
        else
            Dog.new(id:search_result[0],name:search_result[1], breed:search_result[2])
        end
    end

    def self.new_from_db(row)
        Dog.new(id:row[0], name:row[1], breed:row[2])
    end

    def update
        sql= <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end