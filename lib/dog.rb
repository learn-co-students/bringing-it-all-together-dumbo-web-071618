class Dog
attr_accessor  :id, :name, :breed
def initialize(attributes)
    attributes.each {|attr, value| self.send("#{attr}=", value)} 
    
end 

def self.create_table 
    sql = "CREATE TABLE dogs(id  INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
    DB[:conn].execute(sql)

end 

def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)

end


def save 
    if self.id == nil
        sql = "INSERT INTO dogs(name,breed) VALUES(?,?);"
    DB[:conn].execute(sql, self.name,self.breed)
    @id = DB[:conn].execute("SELECT * FROM dogs").flatten[0]
    end 
    self

end 


def self.create(attributes)
  dog = Dog.new(attributes)
  dog.save 
  dog
end

def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1;"

    ans = DB[:conn].execute(sql, id).flatten
   dog = Dog.new(id: ans[0], name: ans[1], breed: ans[2])
   dog.save
   dog
   
end 

def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end


def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    result = DB[:conn].execute(sql, name, breed)
    if !result.empty? 
      dog = self.new_from_db(result.flatten)
      dog 
    else
     dog = self.create(name: name, breed: breed) 
     doggy =  dog.id
     dogs_with_same_name = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
      ans = dogs_with_same_name.flatten.select do |ele|
        ele[0] == doggy

      end 
      Dog.find_by_id(ans.last) 
      

     #doggy  = dog.id
     #puts doggy
     #self.find_by_id(doggy)
    end

end 


def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL
    self.new_from_db(DB[:conn].execute(sql, name).flatten)
  end




end 