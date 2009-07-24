#!/usr/bin/env ruby
if ARGV.length == 0
  puts "#$0 foo.lua"
  exit
end
script = ARGV[0]
system "../src/lua #{script} 2>&1 >/dev/null"
system "mv gcprofile.log Profile/#{script}.gclog"
