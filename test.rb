require 'benchmark/ips'
require_relative 'person'
require_relative 'person3'
require_relative 'gen-rb/person4_types'

# Serializing libs
require 'json'
require 'msgpack'
require 'yaml'
require 'objspace'
require 'protobuf'
require 'google/protobuf'
require 'thrift'

a = Person.new(firstname: 'Bart', lastname: 'Łęcki',
               birthday: Time.new(1992, 8, 25))

a.friends << Person.new(firstname: 'Jack', lastname: 'Robot',
                        birthday: Time.new(1991, 3, 4))
a.friends << Person.new(firstname: 'Anna', lastname: 'Roberts',
                        birthday: Time.new(1984, 5, 10))
a.friends << Person.new(firstname: 'T', lastname: 'Rex',
                        birthday: Time.new(2000, 3, 28))

b = Foo::Person3.new(firstname: 'Bart', lastname: 'Łęcki',
               birthday: Time.new(1992, 8, 25).to_s)

b.friends << Foo::Person3.new(firstname: 'Jack', lastname: 'Robot',
                        birthday: Time.new(1991, 3, 4).to_s)
b.friends << Foo::Person3.new(firstname: 'Anna', lastname: 'Roberts',
                        birthday: Time.new(1984, 5, 10).to_s)
b.friends << Foo::Person3.new(firstname: 'T', lastname: 'Rex',
                        birthday: Time.new(2000, 3, 28).to_s)


c = Person4.new(firstname: 'Bart', lastname: 'Łęcki',
               birthday: Time.new(1992, 8, 25).to_s)

c.friends << Person4.new(firstname: 'Jack', lastname: 'Robot',
                        birthday: Time.new(1991, 3, 4).to_s)
c.friends << Person4.new(firstname: 'Anna', lastname: 'Roberts',
                        birthday: Time.new(1984, 5, 10).to_s)
c.friends << Person4.new(firstname: 'T', lastname: 'Rex',
                        birthday: Time.new(2000, 3, 28).to_s)

thrift_serializer = Thrift::Serializer.new
thrift_deserializer = Thrift::Deserializer.new

Benchmark.ips do |x|
  x.time = 10
  x.warmup = 2

  x.report('Marshal dump') { Marshal::dump(a) }
  x.report('JSON dump') { a.to_json }
  x.report('MsgPack dump') { a.to_msgpack }
  x.report('YAML dump') { YAML::dump(a) }
  # x.report('Protobuf dump') { a.to_protobuf }
  x.report('Protobuf (Foo) dump') { a.to_protobuf_other_class }
  x.report('Google-Protobuf dump') { Foo::Person3.encode(b) }
  x.report('Apache Thrift dump') { thrift_serializer.serialize(c) }

  marshal_dumped = Marshal::dump(a)
  json_dumped = a.to_json
  msgpack_dumped = a.to_msgpack
  yaml_dumped = YAML::dump(a)
  protobuf_dumped = a.to_protobuf
  protobuf_other_class_dumped = a.to_protobuf_other_class
  protobuf3_dumped = Foo::Person3.encode(b)
  thrift_dumped = thrift_serializer.serialize(c)

  x.report('Marshal load') { Marshal::load(marshal_dumped) }
  x.report('JSON load') { Person.from_json(json_dumped) }
  x.report('MsgPack load') { Person.from_msgpack(msgpack_dumped) }
  x.report('YAML load') { YAML::load(yaml_dumped) }
  # x.report('Protobuf load') { Person.from_protobuf(protobuf_dumped) }
  x.report('Protobuf (Foo) load') { Person.from_protobuf_other_class(protobuf_other_class_dumped) }
  x.report('Google-Protobuf load') { Foo::Person3.decode(protobuf3_dumped) }
  x.report('Apache Thrift load') { thrift_deserializer.deserialize(Person4.new, thrift_dumped) }

  puts " ---MEMORY SIZE---"
  puts "Marshal: #{ ObjectSpace.memsize_of(marshal_dumped) }"
  puts "JSON: #{ ObjectSpace.memsize_of(json_dumped) }"
  puts "MessagePack: #{ ObjectSpace.memsize_of(msgpack_dumped) }"
  puts "YAML: #{ ObjectSpace.memsize_of(yaml_dumped) }"
  # puts "Protobuf: #{ ObjectSpace.memsize_of(protobuf_dumped) }"
  puts "Protobuf (Foo): #{ ObjectSpace.memsize_of(protobuf_other_class_dumped) }"
  puts "Google-Protobuf: #{ ObjectSpace.memsize_of(protobuf3_dumped) }"
  puts "Apache Trift: #{ ObjectSpace.memsize_of(thrift_dumped) }"

  puts " ---Serialized objects look--- "
  puts "***MARSHAL***", marshal_dumped.to_s,"**********", "***JSON***"
  puts json_dumped.to_s, "**************", "***MSGPACK***", msgpack_dumped.to_s
  puts "**************", "***YAML***", yaml_dumped.to_s, "**************"
  # puts "***PROTOBUF***", protobuf_dumped.to_s, "*********************"
  puts "***PROTOBUF (FOO)***", protobuf_other_class_dumped.to_s, "******************"
  puts "***GOOGLE-PROTOBUF***", protobuf3_dumped.to_s, "******************"
  puts "***APACHE THRIFT***", thrift_dumped.to_s, "******************"
end

