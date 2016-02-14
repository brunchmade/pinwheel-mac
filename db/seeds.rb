# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

simple_casual   = User.create! name: 'Simple Casual'

message = Message.create! title: 'Simple Casual', content: 'Keep it simple, keep it casual', user: simple_casual
