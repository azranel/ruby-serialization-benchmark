# encoding: utf-8

##
# This file is auto-generated. DO NOT EDIT!
#
require "protobuf"
require 'protobuf/message'

module Foo

  ##
  # Message Classes
  #
  class Person < ::Protobuf::Message; end


  ##
  # Message Fields
  #
  class Person
    required :string, :firstname, 1
    required :string, :lastname, 2
    required :string, :birthday, 3
    repeated ::Foo::Person, :friends, 4
  end

end

