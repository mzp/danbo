# -*- coding: utf-8 -*-
require 'userstream'
require 'pp'

class Danbo
  DEV = '/dev/cu.usbserial-A800eL64'

  def initialize
    @blink = false
    @color = "Dd"
    Thread.start do
      loop do
        %x(echo -n #{@color} > #{DEV})
        if @blink
          sleep 0.5
          %x(echo -n Dd > #{DEV})
          sleep 0.5
        end
      end
    end
  end

  def green; @color = 'Gg'; self end
  def blue; @color = 'Bb'; self end
  def red; @color = 'Rr';self end
  def blink; @blink = true; self end
  def not_blink; @blink = false; self end
end

def twitter(&f)
  consumer_key    = '5EDJM7BXRYkFGL5pzxDMqw'
  consumer_secret = 'ogKYO6X93oJzIHFbOCjbf8ZzQmKXCFMXEre4hNA'
  access_key      = '269769810-cSEEtgBfzYWlqa1pWSMQtYg9uDpwxWEboBAWVAw1'
  access_secret   = 'BdSsx5U8aI58fhveiWiwAvxsFPjvSVODsn5h7C0IBI'

  consumer =
    OAuth::Consumer.new(consumer_key, consumer_secret,
                        :site => 'https://userstream.twitter.com/')
  access_token =
    OAuth::AccessToken.new(consumer,
                           access_key, access_secret)
  userstream = Userstream.new(consumer, access_token)
  userstream.user(&f)
end

if __FILE__ == $0 then
  danbo = Danbo.new
  twitter do |status|
    if status.user.screen_name == '_puke' then
      puts status
      case status.text
      when /開始/
        danbo.blue.blink
      when /成功/
        danbo.green.not_blink
      when /失敗/
        danbo.red.not_blink
      end
    end
  end
end
