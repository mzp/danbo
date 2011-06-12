# -*- coding: utf-8 -*-
require 'pp'
require 'websocket_client'
require 'json'

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

# monkey patch
class WebSocketClient::Protocol::Ietf00
  attr_reader :source
  attr_reader :sink

  def perform_http_prolog(uri)
    key1, key2, key3, solution = generate_keys()

    sink.write_line "GET #{uri.path} HTTP/1.1"
    sink.write_line "Host: #{uri.host}"
    sink.write_line "Connection: upgrade"
    sink.write_line "Upgrade: websocket"
    sink.write_line "Origin: http://#{uri.host}/"
    sink.write_line "Sec-WebSocket-Key1: #{key1}"
    sink.write_line "Sec-WebSocket-Key2: #{key2}"
    sink.write_line ""
    sink.write_line key3
    sink.flush

    while ( ! source.eof? )
      line = source.getline
      break if ( line.strip == '' )
    end

    source.getbytes( 16 )
  end
end

if __FILE__ == $0 then
  danbo = Danbo.new

  WebSocketClient.create('ws://dev.codefirst.org:8081/jenkins') do|ws|
    ws.on_message do|m|
      obj = JSON.parse m
      case obj['result']
      when 'FAILURE'
        danbo.red
      when 'SUCCESS'
        danbo.green
      end
    end
    ws.connect do|c|
      c.wait_for_disconnect
    end
  end
end
