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

        DROP TABLE dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
    
        DB[:conn].execute(sql, self.name, self.breed)

        self
    end

    def self.create(hash)
        dog = Dog.new(name: hash[:name] ,breed: hash[:breed])
        dog.save
        dog
    end

    def self.new_from_db(record)
        dog = Dog.new(
            name: record[1],
            breed: record[2], 
            id: record[0]
            )
        dog
    end

    def self.find_by_id(dog)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        SQL
        found = DB[:conn].execute(sql,dog)[0]
        Dog.new(id: found[0],name:found[1],breed:found[2])
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).first
        if dog
            self.new_from_db(dog)
            
        else
            self.create(name: name, breed: breed)
        end
        
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        
        SQL
        DB[:conn].execute(sql,name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ? WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed,self.id)
    end
end