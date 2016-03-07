class Message < ActiveRecord::Base
  belongs_to :user
  has_many :comments

  def queue_count
    self.comments.enqueued.count
  end
end
