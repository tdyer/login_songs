# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string(255)
#  password_digest :string(255)
#  password_salt   :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

require 'bcrypt'

class User < ActiveRecord::Base
 before_save :encrypt_password

  include BCrypt

  attr_accessor :password

  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :email
  validates_uniqueness_of :email

  has_many :song_collections
  has_many :songs, through: :song_collections

  def active_songs 
    self.songs.merge(SongCollection.active)
  end    

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_digest = BCrypt::Engine.hash_secret(password, self.password_salt)
    else
      nil  
    end
  end


  # authenticate this user
  def self.authenticate(email, password)
    user = User.find_by_email(email)
    if user && user.password_digest == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

end
