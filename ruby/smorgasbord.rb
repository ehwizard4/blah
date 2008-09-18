class Object
  def method_missing sym, args
    msg = "method missing: #{sym}; class of self = #{self.class.name}"
    puts "<p style='color:red;'>#{msg}</p>"
    $stderr.puts "**** #{msg}"
  end
end

def header(level, title)
 puts "<h#{level}>#{title}</h#{level}>"
end
(1..6).each {|i| eval "def h#{i}(title); header(#{i}, title); end" }

def pre
  puts "<pre>"
  yield
  puts "</pre>"
end

def track_table(text=nil)
  puts "<table border='1' cellpadding='4px'>"
  puts "<caption>#{h(text)}</caption>" if text
  puts "<tr style='color:white;background:#333'><th>Id</th><th>Artist</th><th>Album</th><th>Song</th><th>Track</th></tr>"
  yield
  puts "</table>"
end

def br; puts "<br/>"; end

# ****************************************************************

h1 "Ruby Implementation Test"

print "<p><a href=\"/admin/doc?f=/ruby/#{File.basename(__FILE__)}\">[code]</a></p>"

h2 "Create Ruby object from JS class def"
pre {
  f = MyJSClass.new("bar")
  puts "Object.constants.include?('MyJSClass') = #{Object.constants.include?('MyJSClass')}"
  puts "f is of class #{f.class.name}"
  puts "f.inspect = #{f.inspect}"
  puts "f['moo'].getNumParameters = #{f['moo'].getNumParameters}"
  puts "can access f['foo'], but not f.foo because keySet has no foo. f['foo'] = #{f['foo'] }"
  puts "f.moo should be 'rab', it is '#{f.moo()}'"
}

h3 "tojson JS func called with Ruby object"
pre {
  puts tojson(Struct.new(:name, :age).new(:name => 'Jim', :age => 4324))
}

h2 "Scope print"
pre {
  $scope.print("Hello, World!")
}

h3 "Scope print reassignment"
pre {
  puts "We should see stars around the output."
  $scope.print = Proc.new { |str| puts "*** #{str} ***" }
  $scope.print("Hello, World!")
  $scope.print = Proc.new { |str| print str }
}

h2 "Basic Stuff"
pre {
  x = 42
  puts "x = #{x}"

  puts "$data.count = #{$data.count}"
  puts "$data.plus_seven(35) = #{$data.plus_seven(35)}"
  puts "$data.plus_seven(35, 'abc') = #{$data.plus_seven(35, 'abc')}"
}

h2 "Top-Level Funcs Everywhere"
pre {
  puts "should see three hashes, all the same"
  puts tojson({'a' => 1, 'b' => 2})
  def json_inside
    puts tojson({'a' => 1, 'b' => 2})
  end
  json_inside
  class Foo
    def foo
      puts tojson({'a' => 1, 'b' => 2})
    end
  end
  Foo.new.foo()
}

h2 "Database"

song_id = nil
pre {
  puts "Creating data..."
  $db.test.remove({})
  $db.test.save({:artist => 'Thomas Dolby', :album => 'Aliens Ate My Buick', :song => 'The Ability to Swing'})
  $db.test.save({:artist => 'Thomas Dolby', :album => 'Aliens Ate My Buick', :song => 'Budapest by Blimp'})
  $db.test.save({:artist => 'Thomas Dolby', :album => 'The Golden Age of Wireless', :song => 'Europa and the Pirate Twins'})
  $db.test.save({:artist => 'XTC', :album => 'Oranges & Lemons', :song => 'Garden Of Earthly Delights', :track => 1})
  song_id_obj = $db.test.save({:artist => 'XTC', :album => 'Oranges & Lemons', :song => 'The Mayor Of Simpleton', :track => 2})
  $db.test.save({:artist => 'XTC', :album => 'Oranges & Lemons', :song => 'King For A Day', :track => 3})
  song_id = song_id_obj._id
  puts "Data created. song_id = #{song_id}. There are #{$db.test.find.length} records in the test collection."
}

h3 "Find One"

pre {
  # Find a single record with a particular id
  puts "The id I'm looking for is #{song_id}; I expect to see The Mayor Of Simpleton:"
  x = $db.test.findOne(song_id)

  puts "x.class.name = #{x.class.name}"
  puts "x = #{h(tojson(x))}"
  puts "x._id = #{x._id}"
  puts "x.name = # => #{x.song}"

  puts "tojson(x) = #{h(tojson(x))}"
}

h3 "Find"

h4 "search for \"Aliens Ate My Buick\""
pre {
  $db.test.find({:album => "Aliens Ate My Buick"}).each { |row| puts h(tojson(row)) }
}

h4 "all records"
pre {
  $db.test.find.each { |row| puts h(tojson(row)) }
}

h2 "XGen::Mongo::Base"

class Track < XGen::Mongo::Base
  set_collection :test, %w(artist album song track)
  def to_s
    "artist: #{artist}, album: #{album}, song: #{song}, track: #{track ? track.to_i : nil}"
  end
  def to_tr
    str = "<tr>"
    %w(_id artist album song track).each { |s|
      val = instance_variable_get("@#{s}")
      val = val.to_i if s == 'track' && val
      str << "<td>#{val ? h(val) : '&nbsp;'}</td>"
    }
    str << "</tr>"
    str
  end
end

h3 "Testing tojson(pure Ruby object)"
pre {
  t = Track.new({:song => 'New Song', :artist => 'New Artist', :album => 'New Album'})
  puts "tojson(Track.findOne(song_id)) = #{tojson(Track.findOne(song_id))}"
}

# pre {

#   $db.test.setConstructor {  }

#   puts "findOne:"
#   x = $db.test.findOne()
#   puts "findOne class of returned obj = #{x.class.name}"
#   puts "_id of x = #{x._id}"
#   puts "song of x = #{x.song}"

# the old way
#   Track.init($db.test, %w(artist album song track))
# }

h3 "Various uses of find"

track_table("Track.coll.findOne(song_id)") {
  puts Track.new(Track.coll.findOne(song_id)).to_tr
}

br
track_table("Track.findOne(song_id)") {
  puts Track.findOne(song_id).to_tr
}

h3 "Track.find_by_*"
track_table("find_by__id") {
  puts Track.find_by__id(song_id).to_tr
}

br
track_table("find by song 'Budapest by Blimp':") {
  puts Track.find_by_song("Budapest by Blimp").to_tr
}

h3 "Update"

x = Track.find_by_track(2)
track_table("track 2") { puts x.to_tr }

br
x.track = 99
track_table("after incrementing track") { puts x.to_tr }
x.save
puts "saved"

br
track_table("find_by_track(99)") {
  puts Track.find_by_track(99).to_tr
}

br
track_table("find_by_song 'The Mayor Of Simpleton'") {
  puts Track.find_by_song('The Mayor Of Simpleton').to_tr
}

h3 "Track.find"
track_table {
  Track.find.each { |t| puts t.to_tr }
}

h3 "Track.find(:all)"
track_table {
  Track.find(:all).each { |t| puts t.to_tr }
}

h3 "Track.find(:all, {:song => /to/})"
track_table {
  Track.find(:all, {:song => /to/}).each { |row| puts row.to_tr }
}

h3 "Track.find(:all).limit(2)"
track_table {
  Track.find(:all).limit(2).each { |t| puts t.to_tr }
}

h3 "Track.find({:album => 'Aliens Ate My Buick'})"
track_table {
  Track.find({:album => 'Aliens Ate My Buick'}).each { |t| puts t.to_tr }
}

h3 "Track.find(:first)"

track_table("find first, no search params") { puts Track.find(:first).to_tr }

br
track_table("find first, track 3") { puts Track.find(:first, {:track => 3}).to_tr }

h3 "Track.find_all_by_album"

track_table("find_all_by_album('Oranges & Lemons')") {
  Track.find_all_by_album('Oranges & Lemons').each { |t| puts t.to_tr }
}

h3 "Track.new"
track_table {
  puts Track.new.to_tr
}

h3 "Track.new(hash)"
track_table {
  puts Track.new(:artist => 'Level 42', :album => 'Standing In The Light', :song => 'Micro-Kid', :track => 1).to_tr
}

h3 "Track.new(hash).save"
track_table {
  puts Track.new(:artist => 'Level 42', :album => 'Standing In The Light', :song => 'Micro-Kid', :track => 1).save.to_tr
}

h3 "Track.find_or_create_by_song"

track_table("find_or_create_by_song(old_info ...)") {
  puts Track.find_or_create_by_song({:song => 'The Ability to Swing', :artist => 'Thomas Dolby'}).to_tr
}

br
track_table("find_or_create_by_song(new_info ...)") {
  puts Track.find_or_create_by_song({:song => 'New Song', :artist => 'New Artist', :album => 'New Album'}).to_tr
}

h3 "Track.find(:first, {:song => 'King For A Day'}).remove"
t = Track.find(:first, {:song => 'King For A Day'}).remove
track_table("Track.find(:first, {:song => 'King For A Day'}).remove") {
  Track.find(:all).each { |t| puts t.to_tr }
}

h3 "Track.find('bogus_id')"
pre {
  puts "I should see nothing here; a bogus ID should be trapped and the Ruby code should return nil."
  puts Track.find('bogus_id')
}


h2 "require"

# Test require
require 'pp'
pre {
  puts "required 'pp', here is a new track presented using pretty_inspect:"
  puts h(Track.new(:artist => 'Level 42', :album => 'Standing In The Light', :song => 'Micro-Kid', :track => 1).pretty_inspect)
}
