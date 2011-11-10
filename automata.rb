require 'forwardable'
require 'pp'
require 'ffi-ncurses'
require 'pry'

require './random_bit_string'
require './many_params'
require './cell'
require './rule'
require './state_engine'

class Automata
  extend  Forwardable
  include FFI::NCurses
  include Enumerable
  include ManyParams
  include RandomBitString::BitString

module Defaults
  DIMENSIONS = 2
  SIZE = 64
  REACH = 1
  LEAP  = 50
  SPEED = 10
  CONTINUOUS = true

  # Conway's Life
  RULE = '0000000100010110000101110111111000010110011010000111111011101000
          0001011001101000011111101110100001101000100000001110100010000000
          0001011001101000011111101110100001101000100000001110100010000000
          0110100010000000111010001000000010000000000000001000000000000000
          0001011001101000011111101110100001101000100000001110100010000000
          0110100010000000111010001000000010000000000000001000000000000000
          0110100010000000111010001000000010000000000000001000000000000000
          1000000000000000100000000000000000000000000000000000000000000000'

  def self.const_missing(*args); end
end

  attr_reader      :initial_state, :state_engine, :cell_grid, :generation
  init_params      :dimensions, :size, :reach, :rule, :continuous, :leap, :speed, :initial_state
  validated_params :initial_state, :state_engine
  def_delegators   :@state_engine, :reach_range, :norm_reach_range, :norm_size, :transition_map, 
                   :one_d?, :two_d?, :three_d?, :parse, :next!

  def initialize(params = {})
    parse_init_params(params)
    @rule = @rule.is_a?(Rule) ? @rule : Rule.new(@dimensions, @reach, @rule) 
    @state_engine = StateEngine.new(:dimensions => @dimensions, 
                                    :size       => @size, 
                                    :rule       => @rule,
                                    :continuous => @continuous)
    @bit_string = RandomBitString.new(norm_size, :even)
    @initial_state = \
      @initial_state ? RandomBitString.dehumanize(@initial_state) : @bit_string.generate
    @generation = 0
    binding.pry

    return unless valid_params? 
    @cell_grid = parse(@initial_state)
  end

  def run(generations = @leap)
    return false unless valid_params?
    each(generations) {}
  end

  def visual_run(generations = @leap, curses = false)
    return false unless valid_params?
    if curses
      begin
        initscr; noecho
        each(generations) do |g| 
          clear; ref_sleep
          addstr(g.to_s); ref_sleep(2)
        end 
      ensure
        endwin
      end
    else
      each(generations) do |g| 
        one_d? ? puts(g) : puts("#{g}\n\n"); sleep(1.0/@speed)
      end 
    end
  end

  def step
    return false unless valid_params?
    next!(@cell_grid)
    @generation += 1
    self
  end

  def to_s
    if @cell_grid
      grid = ''
      @cell_grid.each_slice(@size) do |s|
        grid << s.join('') + (one_d? ? '' : "\n")
      end; grid
    else super
    end
  end

# private

  def each(generations = @leap)
    generations.times { yield self; step }
    self
  end
  
  def valid_initial_state?
    unless @initial_state.length == norm_size &&
       FORMAT === @initial_state
      puts 'Invalid initial state'
    else  true
    end
  end

  def valid_state_engine?
    unless @state_engine.valid_params?
      @state_engine.invalid_params.each { |p| puts "Invalid #{p}" }
      false
    else true
    end
  end

# curses
  
  def ref_sleep(repeat = 1)
    repeat.times { refresh; sleep(1.0/@speed) }
  end

end
