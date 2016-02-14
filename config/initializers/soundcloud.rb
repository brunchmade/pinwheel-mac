module Soundcloud
  def self.client
    @client = Soundcloud.new(
      :client_id     => ENV['SOUNDCLOUD_ID'],
      :client_secret => ENV['SOUNDCLOUD_SECRET'],
      :redirect_uri =>  ENV['SOUNDCLOUD_REDIRECT']
    )
  end
end
