require 'flickraw'
require 'pry_debug'

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

      if set_id.nil? || set_id.empty?
        file_path                = media_files.shift
        photo_id                 = flickr.upload_photo file_path, :is_public => 0
        uploaded_files[photo_id] = file_path
        set_title                = File.basename(File.dirname(media_files.first))
        photoset                 = flickr.photosets.create(:title => set_title,
                                                           :primary_photo_id => photo_id)
      end

      media_files.each do |file_path|
        photo_id = flickr.upload_photo file_path, :is_public => 0
        uploaded_files[photo_id] = file_path
        puts "SET ID: #{photoset.id} NAME: #{set_title}"

        flickr.photosets.addPhoto(:photoset_id => photoset.id, :photo_id => photo_id)
      end

      {:set_id => photoset.id, :uploaded_files => uploaded_files}
    end
  end
end
