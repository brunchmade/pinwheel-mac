class User < ActiveRecord::Base
  has_many :messages
  has_many :comments

  def full_name
    name = self.soundcloud_response['full_name'].to_s

    if name == ''
      self.soundcloud_response['username'].to_s
    else
      name
    end
  end
end
