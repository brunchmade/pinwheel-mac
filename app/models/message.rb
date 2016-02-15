class Message < ActiveRecord::Base
  belongs_to :user
  has_many :comments

  def queue_count
    self.comments.where(now_playing: false, aired_at: nil).count.to_s
  end
end
