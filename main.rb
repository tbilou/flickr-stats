require 'pry'
require 'flickraw-cached'
require 'csv'
require 'yaml'
require 'diskcached'

def writeCSV(data)
  CSV.open("flickr.csv", "a+") do |csv|
    data.each do |hash|
      #photoset | #photo.name | #date | #url
      csv << [hash[:set], hash[:name], hash[:date], hash[:url]]
    end
  end
end

def getPhotos(set)
  response = @diskcache.cache("#{set.id}1") do
    # Cache the flickr json response
    flickr.photosets.getPhotos :photoset_id => set.id, :page => 1, :extras => 'date_taken,url_o'
  end
  photos = response.photo
  print " | #{response.total} | "
  if response.pages > 1
    for i in 2..response.pages
      print "."
      response = @diskcache.cache("#{set.id}#{i}") do
        # Cache the flickr json response
        flickr.photosets.getPhotos :photoset_id => set.id, :page => i, :extras => 'date_taken,url_o'
      end
      photos += response.photo
    end
  end

  return photos
end

def getDataFromFlickr()
  data = []
  sets = @diskcache.cache('photosets') do
    # Cache the flickr json response
    flickr.photosets.getList :user_id => @login.id
  end

  puts "Found #{sets.photoset.length} photosets..."
  puts "Iterating over sets"
  sets.photoset.each do |set|

    print "| #{set.title}"
    photos = getPhotos(set)

    print " | #{photos.length} \n "

    photos.each do |photo|
      hash = {:set => set.title, :name => photo.title, :date => photo.datetaken, :url => photo['url_o']}
      data.push(hash)
    end
  end
  return data
end


# Enable caching to disk the responses from flickr
@diskcache = Diskcached.new('/tmp/cache', 60*60*24*7) # 7 days worth of cache

# Load Oauth configurations
config = YAML::load_file('config.yaml')

FlickRaw.api_key = config['oauth']['consumer_key']
FlickRaw.shared_secret=config['oauth']['consumer_secret']

flickr.access_token = config['oauth']['token']
flickr.access_secret = config['oauth']['token_secret']

# From here you are logged:
@login = flickr.test.login
puts "You are now authenticated as #{@login.username}"

data = @diskcache.cache('data') do
  getDataFromFlickr()
end

puts "Writting data into a CSV file"
writeCSV(data)

puts ("All Done!")