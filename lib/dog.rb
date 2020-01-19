class Dog
    attr_accessor :id, :name, :breed
    def initialize(hash)
        hash.each {|key,value| public_send("#{key}=",value)}   
        self.id = nil
    end

    def self.create_table
        sql =  <<-SQL 
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
        drop table if exists dogs
        SQL
        DB[:conn].execute(sql)
    end
    def save
        sql = <<-SQL
        insert into dogs(name,breed)
        values(?,?)
        SQL
        DB[:conn].execute(sql,self.name,self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
         self
    end
    def self.create(hash)
        dog = Dog.new(hash)
        dog.save
        dog
    end

    def self.new_from_db(row)
        new_dog = Dog.new(name: row[1],breed: row[2])
        new_dog.id = row[0]
        new_dog
    end
    def self.find_by_id(id)
    sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        LIMIT 1
        SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
    end
    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
          SELECT * FROM dogs
          WHERE name = ? AND breed = ?
          SQL
      
      
          dog = DB[:conn].execute(sql, name, breed).first
      
          if dog
            new_dog = self.new_from_db(dog)
          else
            new_dog = self.create({:name => name, :breed => breed})
          end
          new_dog
    end

    def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
      end
end