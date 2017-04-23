# coding: utf-8
require './sunaemonrt.rb'
require 'clockwork'
include Clockwork

@sunaemon = SunaemonRT.new()

every(5.minutes, 'work') {
  @sunaemon.work()
}

every(1.hour, 'follow_return') {
  @sunaemon.follow_return()
}

every(1.day, 'report', :at => '00:05') {
  @sunaemon.report()
}
