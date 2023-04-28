require 'json'

# mixin
module BasicSerializable
  # should point to a class; change to a different
  # class (e.g. MessagePack, JSON, YAML) to get a different
  # serialization
  @@serializer = JSON

  def serialize
    obj = {}
    instance_variables.map do |var|
      obj[var] = instance_variable_get(var)
    end

    @@serializer.dump obj
  end

  def unserialize(string)
    obj = @@serializer.parse(string)
    obj.keys.each do |key|
      instance_variable_set(key, obj[key])
    end
  end
end

class Person
  include BasicSerializable

  attr_accessor :name, :age, :gender

  def initialize(name, age, gender)
    @name = name
    @age = age
    @gender = gender
  end
end

class People
  include BasicSerializable

  attr_accessor :persons

  def initialize
    @persons = []
  end

  # def serialize
  #   obj = @persons.map do |person|
  #     person.serialize
  #   end

  #   @@serializer.dump obj
  # end

  # def unserialize(string)
  #   obj = @@serializer.parse string
  #   @persons = []
  #   obj.each do |person_string|
  #     person = Person.new "", 0, ""
  #     person.unserialize(person_string)
  #     @persons << person
  #   end
  # end

  def <<(person)
    @persons << person
  end
end

person = Person.new('dylan', 38, 'male')
serialized_string = person.serialize

p person
p serialized_string

person2 = Person.new('', 0, '')

p person2

person2.unserialize(serialized_string)

p person2

puts "\n"

people = People.new
people << person

serialized_string = people.serialize

p people
p people.persons[0].name
p serialized_string

people2 = People.new

p people2

people2.unserialize(serialized_string)

p people2

p people2.persons[0].name
