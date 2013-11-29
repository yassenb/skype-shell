#!/usr/bin/env ruby

require_relative '../lib/raw-api-client'

c = SkypeShell::RawAPIClient.new
c.on_receive do |message|
  puts '>>> ' + message
end

Thread.new { c.run }

while true
  s = gets.strip
  break if s == 'q'
  unless s.empty?
    c.send(s).each do |message|
      puts '>>> ' + message.to_s
    end
  end
end
