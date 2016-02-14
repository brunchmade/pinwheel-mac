class Comment < ActiveRecord::Base
  include ApplicationHelper

  belongs_to :message
  belongs_to :user

  before_create :resolve
  # after_commit { CommentRelayJob.perform_later(self) }
  after_create :push

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
    if Comment.where(now_playing: true).count == 0
      self.now_playing = true
      self.aired_at = Time.now.utc
      self.save
      push_track(self)
    else
      Pusher.trigger('message_' + self.message.id.to_s, 'on_deck', {
        message: ApplicationController.render(
          assigns: { comment: self },
          template: 'comments/_comment'
        )
      })
    end
  end
end
