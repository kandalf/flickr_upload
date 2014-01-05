require 'flickraw'
require 'json'

module FlickrSyncd
  class Authenticator
    @@config = {}
    @@config_file = ""

    def self.load_settings(config_file)
      @@config_file = config_file
      @@config = JSON.parse(File.read(config_file))
      FlickrSyncd::Authenticator.client_key = @@config["client_key"]
      FlickrSyncd::Authenticator.client_secret = @@config["client_secret"]
      FlickrSyncd::Authenticator.access_token = @@config["access_token"]
      FlickrSyncd::Authenticator.access_secret = @@config["access_secret"]
    end

    def self.flush_settings
      unless @@config_file.empty?
        File.open(@@config_file, "w") do |f|
          f.puts @@config.to_json
        end
      end
    end

    def self.client_key=(key)
      @@config["client_key"] = key
      FlickRaw.api_key = @@config["client_key"]
    end

    def self.client_secret=(secret)
      @@config["client_secret"] = secret
      FlickRaw.shared_secret = @@config["client_secret"]
    end

    def self.access_token=(token)
      @@config["access_token"] = token
      flickr.access_token = @@config["access_token"]
    end

    def self.access_secret=(secret)
      @@config["access_secret"] = secret
      flickr.access_secret = @@config["access_secret"]
    end

    def self.user_id
      @@config["user_id"]
    end

    def self.user_name
      @@config["user_name"]
    end

    def self.needs_authorization?
      !(@@config["access_token"] && @@config["access_secret"])
    end

    def self.credentials
      {:user_name => self.user_name, :user_id => self.user_id}
    end

    def self.authorize
      token       = flickr.get_request_token
      auth_url    = flickr.get_authorize_url(token['oauth_token'], :perms => 'write')
      {:token_data => token,
       :auth_url => auth_url}
    end

    def self.authenticate(oauth_token, oauth_token_secret, verify_code)
      begin
        flickr.get_access_token(oauth_token, oauth_token_secret, verify_code)
      rescue FlickRaw::FailedResponse =>
        e.message
      end
    end

    def self.login
      login = flickr.test.login

      if @@config["access_token"] != flickr.access_token &&
         @@config["access_secret"] != flickr.access_secret
          self.access_token  = flickr.access_token
          self.access_secret = flickr.access_secret
      end

      if login["id"] != @@config["user_id"]
        @@config["user_id"]   = login["id"]
        @@config["user_name"] = login["username"]
      end

      self.flush_settings
      login
    end
  end
end
