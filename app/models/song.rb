# == Schema Information
#
# Table name: songs
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text
#  url         :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Song < ActiveRecord::Base
end
