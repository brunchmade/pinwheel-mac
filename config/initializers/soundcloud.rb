module Soundcloud
  def self.client
    @client = Soundcloud.new(
  :client_id     => 'b59d1f4b68bbc8f2b0064188f210117d',
  :client_secret => 'bed0d37bd0eed984cb6d30bf4ee3a2e0',
  :redirect_uri => 'http://localhost:5000/soundcloud/callback'
    )
  end
end
