require 'yaml'
require 'json'

class Person
  attr_accessor :name, :age, :gender

  def initialize(name, age, gender)
    @name = name
    @age = age
    @gender = gender
  end

  def to_yaml
    YAML.dump ({
      :name => @name,
      :age => @age,
      :gender => @gender
      # 'name' => @name,
      # 'age' => @age,
      # 'gender' => @gender
    })
  end

  def to_json
    JSON.dump ({
      :name => @name,
      :age => @age,
      :gender => @gender
      # 'name' => @name,
      # 'age' => @age,
      # 'gender' => @gender

    })
  end
  
  def self.from_yaml(string)
    p string
    data = YAML.load string
    p data
    self.new(data[:name], data[:age], data[:gender])
    # self.new(data['name'], data['age'], data['gender'])
  end

  def self.from_json(string)
    p string
    data = JSON.load string
    p data
    self.new(data['name'], data['age'], data['gender'])
    # self.new(data[:name], data[:age], data[:gender]) # Does not work. Key must be string
  end

  def self.yaml_to_file(string)
    filename = "yaml_output.yaml"
  
    File.open(filename, 'w') do |file|
      file.puts string
    end
  end
  
  def self.json_to_file(string)
    filename = "json_output.json"
  
    File.open(filename, 'w') do |file|
      file.puts string
    end
  end
end

p = Person.new "David", 28, "male"

p = Person.from_yaml(p.to_yaml)

puts "Name #{p.name}"
puts "Age #{p.age}"
puts "Gender #{p.gender}"

Person.yaml_to_file(p.to_yaml)

p YAML.load File.read('yaml_output.yaml')



# p = Person.new "David", 28, "male"

# p = Person.from_json(p.to_json)

# puts "Name #{p.name}"
# puts "Age #{p.age}"
# puts "Gender #{p.gender}"

# Person.json_to_file(p.to_json)

# p JSON.load File.read('json_output.json')
