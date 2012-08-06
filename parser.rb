require 'net/http'
require 'nokogiri'
require 'active_support/core_ext/numeric/time.rb'
class Parser
  attr_accessor :username, :pomodoro_url
  def initialize(username)
    self.username = username
    @pomodoro_url = "http://tomatoi.st/#{@username}"
  end
  def username=(username)
    @username=username
    @pomodoro_url = "http://tomatoi.st/#{@username}"
  end
  def content
    uri = URI(pomodoro_url)
    res = Net::HTTP.get_response(uri).body
    return res
  end
  def nokogirize(res)
    Nokogiri.parse(res)
  end
  def pomodoros
    doc = nokogirize(self.content)
    pomos = []
    doc.css('li').each do |li|
      pomo={}
      type = "Pomodoro" if li.children.text["Pomodoro"]
      type = 'Short Break' if li.children.text["Short Break"]
      type = "Long Break" if li.children.text["Long Break"]
      time_text = li.children.css(".time").text
      pomo["type"] = type
      pomo["time"] = parse_time(time_text)
      pomos.push(pomo)
    end
    return pomos
  end
  def parse_time(time_text)
    if time_text["about"]
      string_time = time_text.split("about\s").last.split("\n").first
      string_time = string_time.split("\s").map {|s| if s["\d"] then s.to_i else s end }
      approximate_time = Time.now - string_time[0].to_i.send(string_time[1])
    else 
      approximate_time = Time.now - 1.minute
    end
    return approximate_time
  end
end