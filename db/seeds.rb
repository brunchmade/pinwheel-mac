# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

wells   = User.create! name: 'Wells Riley'
baldwin = User.create! name: 'Alex Baldwin'
abby = User.create! name: 'Abby Culin'

message = Message.create! title: 'Simple Casual', content: 'Keep it simple, keep it casual', user: baldwin
Comment.create! message: message, content:'https://soundcloud.com/beatsbyesta/hotline-bling', user: baldwin
