require 'pry'

class Dog
  attr_accessor :id, :name, :breed

  def initialize(attributes)
    attributes.each do |key, value|
      if self.respond_to?("#{key}=")
        self.send(("#{key}="), value)
      end
    end
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
    SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    new_dog = Dog.new(name: row[1], breed: row[2])
    new_dog.id = row[0]
    new_dog
  end

  def save
    if self.id
      self.update
      self
    else
      self.insert
      self.id = @dog_id
      self
    end
  end

  def self.create(attributes)
    new_hash = {}
    attributes.each do |key, value|
      new_hash[key] = value
    end
    new_dog = Dog.new(new_hash)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?;
    SQL
    dog_specs = DB[:conn].execute(sql, id)[0]
    self.new_from_db(dog_specs)
  end

  def self.find_or_create_by(attributes)

    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ?;
    SQL
    dog_specs = DB[:conn].execute(sql, attributes[:name], attributes[:breed])[0]

    if dog_specs.nil?
      self.create(attributes)
    else self.new_from_db(dog_specs)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?;
    SQL

    dog_specs = DB[:conn].execute(sql, name)[0]
    self.new_from_db(dog_specs)
  end
# PRIVATE

  def insert
    sql = <<-SQL
    INSERT INTO dogs (name, breed) VALUES (?, ?);
    SQL

    DB[:conn].execute(sql, self.name, self.breed)[0]

    @dog_id = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? GROUP by id ORDER BY id DESC LIMIT 1;", self.name)[0][0]
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)[0]
  end
end
