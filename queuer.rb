# parse songlists into artist song time structs

Entry = Struct.new(:begin, :artist, :song)
MUSICDIR = "/home/user/Music"
def getBeginTime(line)
  match = line.match(/\d*:?\d+:\d+/).to_s
  return match
end

def parseEntry(line)
  begin_time = getBeginTime(line)
  result = line.sub(begin_time, "").lstrip.rstrip
  result = result.reverse.split(/ [^\w] /).map(&:reverse)
  return Entry.new(begin_time, result.last, result.first)
end

def formatTime(begin_time)
  # takes the track time as a string a la 3:34
  min_sec = begin_time.split(":")
  if min_sec.size < 3
    return "INDEX 01 #{(min_sec[0]).rjust(2, "0")}:#{min_sec[1]}:00"
  else
    hr_min = min_sec[0].to_i * 60 + min_sec[1].to_i
    return "INDEX 01 #{hr_min}:#{min_sec[2]}:00"
  end
end

def formatTracks(entry_list)
  dat = ""
  entry_list.each_index do |entry|
    dat += "  TRACK %02d AUDIO\n" % [entry + 1]
    dat += "    TITLE \"#{entry_list[entry].song}\"\n"
    dat += "    PERFORMER \"#{entry_list[entry].artist}\"\n"
    dat += "    #{formatTime(entry_list[entry].begin)}\n"
  end
  return dat
end

def makeCueFile(entry_list, artist, album, mp3_file)
  dat = ""
  dat += "TITLE \"#{album}\"\n"
  dat += "PERFORMER \"#{artist}\"\n"
  dat += "FILE \"#{mp3_file}\" MP3\n"
  dat += formatTracks(entry_list)
  return dat
end

mp3_file = ARGV[0]
track_file = ARGV[1]
artist = ARGV[2]
album = ARGV[3]

if ARGV.size < 2
   puts "usage: queuer.rb file.mp3 track.list performer album"
   exit
end

data = File.open(track_file).read
entry_list = data.split("\n").map { |s| parseEntry(s) }

cue_file = File.open("./tmp/cuefile.cue", "wb")
cue_file.write(makeCueFile(entry_list, artist, album, mp3_file))
cue_file.close

system("mp3splt -a -c ./tmp/cuefile.cue \"#{mp3_file}\" -d \"#{MUSICDIR}/#{artist} - #{album}\"")


