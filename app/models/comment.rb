class Comment < ActiveRecord::Base
  belongs_to :message
  belongs_to :user

  before_create :resolve
  # after_commit { CommentRelayJob.perform_later(self) }
  after_commit :push

  private

  def resolve
  client = SoundCloud.new({
  :client_id     => 'b59d1f4b68bbc8f2b0064188f210117d',
  :client_secret => 'bed0d37bd0eed984cb6d30bf4ee3a2e0'
})
  track = client.get('/resolve', :url => self.content)
    self.responses = track.to_json
  end

  def push
    Pusher.trigger('message_' + self.message.id.to_s, 'now_playing', {
      title:          self.responses['title'].to_s,
      artist:         self.responses['user']['username'].to_s,
      artwork_url:    self.responses['artwork_url'].to_s.gsub('large','t500x500'),
      stream_url:     self.responses['stream_url'].to_s + '?client_id=b59d1f4b68bbc8f2b0064188f210117d'
    })
  end
end
