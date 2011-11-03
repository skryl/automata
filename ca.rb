#!/usr/bin/env ruby

require './automata'

Automata.new(:size => 50, :speed => 30).visual_run(100, true)
# Automata.new(:dimensions => 1, :reach => 3, :size => 100, :speed => 60, :rule => '01100001001101000000010000010000100101000000000000000010000001000000000000110010000100111000000000011011110000001101001010001010').visual_run(1000, false)
