class Message < ActiveRecord::Base
  belongs_to :user
  has_many :comments

  def mvdj
    grouped_track_count = self.comments.group(:user_id).count
    sorted_group = grouped_track_count.sort_by { |user_id, count| -count }
    User.find_by(id: sorted_group.first)
  end

  def played_tracks
    self.comments.where.not(aired_at: nil)
  end

  def queue_count
    self.comments.enqueued.count
  end

  def total_played_hours
    seconds = played_tracks.reduce(0) { |sum, track| sum + track.duration }
    (seconds.to_f / 60.0 / 60.0).round(2)
  end
end
