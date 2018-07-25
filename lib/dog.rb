class Dog
  attr_accessor :id,:name,:breed
  def initialize attributes
    @id = attributes[:id]
    @name = attributes[:name]
    @breed = attributes[:breed]
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INT PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute sql
  end

  def self.drop_table
    DB[:conn].execute "DROP TABLE dogs"
  end

  def save
    if self.id
      update
    else
      sql = <<-SQL
        INSERT INTO dogs (name,breed) VALUES (?,?)
      SQL

      DB[:conn].execute sql,@name,@breed
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    specs = DB[:conn].execute("SELECT * FROM dogs ORDER BY id DESC LIMIT 1")[0]
    dog = Dog.new id: specs[0],name: specs[1],breed:specs[2]
    dog
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?,breed = ? WHERE id = ?
    SQL
    DB[:conn].execute sql, @name,@breed,@id
  end

  def self.create attributes
    dog = Dog.new attributes
    dog.save
    dog
  end

  def self.find_by_id id
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    doggie = DB[:conn].execute(sql,id)[0]
    doggie = Dog.new id: doggie[0],name: doggie[1],breed: doggie[2]
    doggie
  end

  def self.find_or_create_by attributes
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL

    doggie = DB[:conn].execute(sql,attributes[:name],attributes[:breed])

    if !doggie.empty?
      Dog.find_by_id(doggie[0][0])
    else
      Dog.create name: doggie[0], breed: doggie[1]
    end
  end

  def self.new_from_db row
    Dog.new id: row[0], name: row[1], breed: row[2]
  end

  def self.find_by_name name
    doge = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?",name)[0]
    Dog.new id: doge[0],name: doge[1], breed: doge[2]
  end

end
