require 'flickraw'

module FlickrSyncd
  class FlickrAccount
    attr_accessor :user_id, :user_name

    def initialize(options = {})
      @user_id = options["user_id"] || options[:user_id]
      @user_name = options["user_name"] || options[:user_name]
    end

    def photos
      flickr.photos.search(:user_id => @user_id)
    end

    def upload_to_set(media_files, set_id = nil)
      uploaded_files = {}

      if media_files.any? && (set_id.nil? || set_id.empty?)
        file_path                = media_files.shift
        photo_id                 = flickr.upload_photo file_path, :is_public => 0
        uploaded_files[photo_id] = file_path
        set_title                = File.basename(File.dirname(file_path))
        photoset                 = flickr.photosets.create(:title => set_title,
                                                           :primary_photo_id => photo_id)
        set_id = photoset.id
        FlickrSyncd::Set.create(:id => set_id, :name => set_title)
      end

      media_files.each do |file_path|
        photo_id = flickr.upload_photo file_path, :is_public => 0
        uploaded_files[photo_id] = file_path
        puts "SET ID: #{set_id} NAME: #{set_title}"

        flickr.photosets.addPhoto(:photoset_id => set_id, :photo_id => photo_id)

        FlickrSyncd::Photo.create(:id => photo_id, :title => file_path, :set_id => set_id, :user_id => FlickrSyncd::Authenticator.user_id)
      end

      {:set_id => set_id, :uploaded_files => uploaded_files}
    end
  end
end
