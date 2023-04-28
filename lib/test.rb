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
    })
  end

  def to_json
    JSON.dump ({
      :name => @name,
      :age => @age,
      :gender => @gender
    })
  end

  def yaml_to_file(string)
    filename = "yaml_output.yaml"
  
    File.open(filename, 'w') do |file|
      file.puts string
    end
  end

  def self.from_yaml(string)
    p string
    data = YAML.load string
    p data
    self.new(data[:name], data[:age], data[:gender])
  end

  def self.from_json(string)
    data = JSON.load string
    self.new(data['name'], data['age'], data['gender'])
  end
end

p = Person.new "David", 28, "male"
# p p.to_yaml

p = Person.from_yaml(p.to_yaml)

puts "Name #{p.name}"
puts "Age #{p.age}"
puts "Gender #{p.gender}"