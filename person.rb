require 'set'
require './person.pb'

class Person < ::Protobuf::Message; end

class Person
  attr_accessor :firstname, :lastname, :birthday
  attr_accessor :friends

  def initialize(args = [])
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
    @friends ||= Set.new
    birthday = Time.new(birthday) if birthday.is_a?(String)
    friends = Set.new(friends) if friends.is_a?(Hash)
  end

  def age
    Time.now.year - birthday.year
  end

  def to_msgpack
    to_hash.to_msgpack
  end

  def to_protobuf
    self.encode
  end

  def to_protobuf_other_class
    Foo::Person.new(to_hash).encode
  end

  def self.from_protobuf(bytes)
    self.decode(bytes)
  end

  def self.from_protobuf_other_class(bytes)
    person = Foo::Person.decode(bytes)
    self.new(firstname: person.firstname, lastname: person.lastname,
             birthday: person.birthday, friends: person.friends)
  end



  def self.from_msgpack(bytes)
    data = MessagePack.load(bytes)
    self.new(data)
  end

  def to_json()
    to_hash.to_json
  end

  def self.from_json(bytes)
    args = JSON::parse(bytes)
    self.new(args)
  end

  def to_hash
    { firstname: firstname, lastname: lastname, birthday: birthday.to_s, friends: friends.map { |f| f.to_hash } }
  end

  def to_s
    "#{firstname} #{lastname} #{age}"
  end
end
