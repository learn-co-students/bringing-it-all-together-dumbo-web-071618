require 'pry'
class Dog
    
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE (name, breed) = (?, ?)
        SQL
        row = DB[:conn].execute(sql, self.name, self.breed)[0]
        self.id = row[0]
        self
    end

    def self.create(attrs_hash)
        (self.new(attrs_hash)).save
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
        SQL
        row = DB[:conn].execute(sql, id)[0]
        new_dog = Dog.new(name: row[1], breed: row[2])
        new_dog.id = row[0]
        new_dog
    end

    def self.find_or_create_by(attrs_hash)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE (name, breed) = (?, ?)
        SQL
        row = DB[:conn].execute(sql, attrs_hash[:name], attrs_hash[:breed])[0]
        if row.nil?
            self.create(attrs_hash)
        else
            self.find_by_id(row[0])
        end
    end

    def self.new_from_db(row)
        self.create(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?
        SQL
        row = DB[:conn].execute(sql, name)[0]
        self.new_from_db(row)
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end