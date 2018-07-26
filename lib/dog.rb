class Dog
attr_accessor :name,:breed,:id


  def initialize(attributes)
    attributes.each{|key,value| self.send("#{key}=",value)}
  end

  def self.create_table
    sql=<<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql=<<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql=<<-SQL
      INSERT INTO dogs (name,breed)
      VALUES (?,?)
    SQL
    dog = DB[:conn].execute(sql,self.name,self.breed)
    @id = DB[:conn].execute("SELECT id FROM dogs ORDER BY id DESC LIMIT 1")[0][0]
    self
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
  end

  def self.find_by_id(id)
    sql=<<-SQL
    SELECT * FROM dogs WHERE id = #{id}
    SQL
    dog_array = DB[:conn].execute(sql)[0]
    Dog.new_from_db(dog_array)
  end

  def self.new_from_db(row)
    hash = {id: row[0],name: row[1],breed: row[2]}
    return dog = Dog.new(hash)
  end

  def self.find_or_create_by(attributes)
    sql=<<-SQL
      SELECT * FROM dogs WHERE name = '#{attributes[:name]}' AND breed = '#{attributes[:breed]}'
    SQL
    dog_array = DB[:conn].execute(sql)[0]
    if dog_array.nil?
      Dog.create(attributes)
    elsif !dog_array.empty?
      Dog.new_from_db(dog_array)
    end
  end

  def self.find_by_name(name)
    sql=<<-SQL
      SELECT * FROM dogs WHERE name = '#{name}'
    SQL
    Dog.new_from_db(DB[:conn].execute(sql)[0])
  end

  def update
    sql =<<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name,self.breed,self.id )
  end

end
