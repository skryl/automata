class Rule
  extend  Forwardable
  include ManyParams
  include RandomBitString::BitString

  MUTATION_FACTOR = 0.1
  SLICE_SIZE = 1
  OFFSPRING = 1

  attr_reader      :reach, :reach_range, :norm_reach_range
  validated_params :rule
  def_delegators   :@rule, :to_s, :[], :[]=, :length

  def initialize(dimensions, reach, rule)
    @dimensions, @reach, @rule = dimensions, reach, RandomBitString.dehumanize(rule)
    @reach_range = (@reach * 2 + 1)
    @norm_reach_range = @reach_range ** @dimensions
  end

  def mutate!
    mutations = (length * MUTATION_FACTOR).to_i
    mutation_indeces = (0...mutations).inject([]) { |ind, i| ind << rand(length) }
    mutation_indeces.each do |i|
      self[i] = (self[i] == ON ? OFF : ON)
    end
  end

  # rule sex
  def +(rule)
    p1 = to_s.split('').each_slice(SLICE_SIZE).to_a
    p2 = rule.to_s.split('').each_slice(SLICE_SIZE).to_a

    (0...OFFSPRING).inject([]) do |o, oi|
      offspring = Array.new(length, OFF)
      length.times { |i| offspring[i] = [p1,p2][rand(2)][i] }
      o << Rule.new(@dimensions, @reach, offspring.join(''))
    end
  end

private

  def valid_rule?
    (2 ** @norm_reach_range) == @rule.length &&
    FORMAT === @rule
  end

end
