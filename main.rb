require 'flickraw-cached'
require 'pry'
require 'csv'
require 'yaml'

def getPhotos(set)

  response = flickr.photosets.getPhotos :photoset_id => set.id, :page => 1, :extras => 'date_taken,url_o'
  photos = response.photo
  print " | #{response.total} | "
  if response.pages > 1
    for i in 2..response.pages
      print "."
      response = flickr.photosets.getPhotos :photoset_id => set.id, :page => i, :extras => 'date_taken,url_o'
      photos += response.photo
    end
  end

  return photos
end

config = YAML::load_file('config.yaml')

FlickRaw.api_key = config['oauth']['consumer_key']
FlickRaw.shared_secret=config['oauth']['consumer_secret']

flickr.access_token = config['oauth']['token']
flickr.access_secret = config['oauth']['token_secret']

# From here you are logged:
login = flickr.test.login
puts "You are now authenticated as #{login.username}"

sets = flickr.photosets.getList :user_id => login.id

puts "Found #{sets.photoset.length} photosets..."
puts "Iterating over sets"

sets.photoset.each do |set|

  print "| #{set.title}"
  photos = getPhotos(set)

  print " | #{photos.length} \n "

  CSV.open("flickr.csv", "a+") do |csv|
    photos.each do |photo|
      #photoset | #photo.name | #date | #url
      csv << [set.title, photo.title, photo.datetaken, photo['url_o']]
    end
  end
end


