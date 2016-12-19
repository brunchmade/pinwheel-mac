class Comment < ActiveRecord::Base
  include Imgix::Rails::UrlHelper

  belongs_to :message
  belongs_to :user

  before_create :resolve

  scope :enqueued, -> { where(now_playing: false, aired_at: nil).order(created_at: :asc) }
  scope :playing, -> { where(now_playing: true).order(created_at: :asc) }

  def album_art_url
    if self.responses.dig('artwork_url').to_s != ''
      self.responses['artwork_url'].to_s.gsub('large','t500x500')
    elsif self.responses.dig('user', 'avatar_url').to_s != ''
      self.responses['user']['avatar_url'].to_s.gsub('large','t500x500')
    else
      'https://i1.sndcdn.com/avatars-000106486517-x71ahg-large.jpg'
    end
  end

  def blurred_album_art_url
    ix_image_url(album_art_url, { blur: 200 })
  end

  def duration
    (self.responses['duration'] / 1000).ceil
  end

  def palette_url
    ix_image_url(album_art_url, { palette: 'css', colors: 4, class: 'album', zoom: 100 })
  end

  def reset!
    update_attributes(aired_at: nil, now_playing: false)
  end

  def start_playing(should_push)
    now = Time.now.utc
    update_attributes(now_playing: true, aired_at: now)
    next_track_at = now + duration
    NextUpJob.set(wait_until: next_track_at).perform_later(self.message.id, self.id)
    PusherService.now_playing_track(self) if should_push
  end

  private

  def resolve
    client = SoundCloud.new({
      client_id:     ENV['SOUNDCLOUD_ID'],
      client_secret: ENV['SOUNDCLOUD_SECRET']
    })
    response = client.get('/resolve', url: self.content)
    if response['kind'] == 'playlist'
      first = response['tracks'].first
      self.content = first['permalink_url']
      self.responses = first.to_json
      tracks = response['tracks']
      tracks.delete(first)
      tracks.each do |comment|
        if @comment = self.message.comments.create(content: comment['permalink_url'], user: self.user)
          PusherService.add_track(@comment)
        end
      end
    else
      self.responses = response.to_json
    end
  end
end
