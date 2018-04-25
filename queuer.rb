# parse songlists into artist song time structs

Entry = Struct.new(:begin, :artist, :song)
data = File.open('songlist.txt').read
data_split = data.split("\n")

def getBeginTime(line)
  match = line.match(/\d*:?\d+:\d+/).to_s
  return match
end

def parseEntry(line)
  begin_time = getBeginTime(line)
  result = line.sub(begin_time, "").lstrip.rstrip
  result = result.split(/ [^\w] /)
  return Entry.new(begin_time, result.first, result.last)
end

out = data_split.map { |s| parseEntry(s) }
out.each { |s| printf "%s %s - %s", s.begin, s.artist, s.song }
