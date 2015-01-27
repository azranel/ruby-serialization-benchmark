require 'benchmark/ips'
require_relative 'person'

# Serializing libs
require 'json'
require 'msgpack'
require 'yaml'
require 'objspace'

a = Person.new(firstname: 'Bart', lastname: 'Łęcki',
               birthday: Time.new(1992, 8, 25))

a.friends << Person.new(firstname: 'Jack', lastname: 'Robot',
                        birthday: Time.new(1991, 3, 4))
a.friends << Person.new(firstname: 'Anna', lastname: 'Roberts',
                        birthday: Time.new(1984, 5, 10))
a.friends << Person.new(firstname: 'T', lastname: 'Rex',
                        birthday: Time.new(2000, 3, 28))

Benchmark.ips do |x|
  x.time = 10
  x.warmup = 2

  x.report('Marshal dump') { Marshal::dump(a) }
  x.report('JSON dump') { a.to_json }
  x.report('MsgPack dump') { a.to_msgpack }
  x.report('YAML dump') { YAML::dump(a) }

  marshal_dumped = Marshal::dump(a)
  json_dumped = a.to_json
  msgpack_dumped = a.to_msgpack
  yaml_dumped = YAML::dump(a)

  x.report('Marshal load') { Marshal::load(marshal_dumped) }
  x.report('JSON load') { JSON::parse(json_dumped) }
  x.report('MsgPack load') { Person.from_msgpack(msgpack_dumped) }
  x.report('YAML load') { YAML::load(yaml_dumped) }

  puts " ---MEMORY SIZE---"
  puts "Marshal: #{ ObjectSpace.memsize_of(marshal_dumped) }"
  puts "JSON: #{ ObjectSpace.memsize_of(json_dumped) }"
  puts "MessagePack: #{ ObjectSpace.memsize_of(msgpack_dumped) }"
  puts "YAML: #{ ObjectSpace.memsize_of(yaml_dumped) }"
end


