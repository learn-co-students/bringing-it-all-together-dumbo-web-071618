require "pry"

class Dog
  attr_accessor :id, :name, :breed

  def initialize(attributes)
    attributes.each do |attribute, value|
      if self.respond_to?"#{attribute}="
        self.send "#{attribute}=", value
      end
    end
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (id INTEGER PRIMARY KEY,
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
      INSERT INTO dogs (name, breed) VALUES(?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)

    self.id =  DB[:conn].execute("SELECT id FROM dogs ORDER BY id DESC LIMIT 1")[0][0]
    self
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    dog_array = DB[:conn].execute(sql, id)[0]
    self.new_from_db(dog_array)
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL

    dog = DB[:conn].execute(sql, hash[:name], hash[:breed])
    if !dog.empty?
      self.find_by_id(dog[0][0])
    else
      self.create(hash)
    end
  end

  def self.new_from_db(row)
    dog_hash = {:id => row[0], :name => row[1], :breed => row[2]}
    new_dog = Dog.new(dog_hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    dog = DB[:conn].execute(sql, name)[0]
    self.new_from_db(dog)
  end

  def update
    id = self.id
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
