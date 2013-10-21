# == Schema Information
#
# Table name: song_collections
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  song_id    :integer
#  active     :boolean
#  created_at :datetime
#  updated_at :datetime
#

class SongCollection < ActiveRecord::Base
  belongs_to :user
  belongs_to :song

  scope :active, lambda { where(active: true)}

  # def self.active
  #   self.where(active: true)
  # end
end
