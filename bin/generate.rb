#!/usr/bin/env ruby
require 'active_record'
require 'faker'
require 'pry'

class Record < ActiveRecord::Base
  self.abstract_class = true
  self.logger = Logger.new STDOUT
  self.pluralize_table_names = false # to match Yesod

  self.establish_connection \
    adapter:  'postgresql',
    database: 'haskore',
    username: 'haskore'
end

class User < Record
  has_many :posts, foreign_key: 'author_id'
end

class Board < Record
  has_many :posts
end

class Post < Record
  belongs_to :board
  belongs_to :author, class_name: 'User'
end

class Generator
  include Faker

  Quotables = Faker.constants.each_with_object([]) do |name, list|
    mod = Faker.const_get name
    if mod.respond_to? :quote
      list.push mod
    end
  end

  def reset!
    Record.subclasses.each &:delete_all
  end

  def users n
    Array.new(n).map do
      User.create! \
        ident:    Name.name,
        password: 'hunter2'
    end
  end

  def boards n
    Array.new(n).map do
      Board.create! \
        title: Company.bs.titleize
    end
  end

  def posts n, user:, boards:
    Array.new(n).map do
      user.posts.create! \
        board: boards.sample,
        title: Quotables.sample.quote,
        body:  Lorem.paragraph
    end
  end

  def run
    users  = self.users 30
    boards = self.boards 10

    users.flat_map do |user|
      subs = boards.sample rand 1 .. 5
      verbosity = rand 0 .. 10

      posts subs * verbosity, user: user, boards: boards
    end
  end
end

if $PROGRAM_NAME == __FILE__
  posts = Generator.new.run
  
  binding.pry
end
