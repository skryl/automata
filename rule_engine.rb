require './automata'

class RuleEngine

  SEED_SIZE = 500
  SELECTION_FACTOR = 2
  GENERATIONS = 100
  TEST_ITERATIONS = 100

  INPUT_CHECK  = lambda { |initial_state| initial_state.count('1') > initial_state.size/2 }
  OUTPUT_CHECKS = { true  => lambda { |final_state| final_state.count('X') == final_state.size },
                    false => lambda { |final_state| final_state.count(' ') == final_state.size } }
  OUTPUT_SET_CHECK = lambda { |output_set, size| output_set.all? { |o| ['X' * size, ' ' * size].include? o } }

  attr_reader :size, :reach, :population

  def initialize(dimensions, reach, size)
    @dimensions, @size, @reach = dimensions, size, reach
    @rule_size = 2 ** (@reach * 2 + 1)
    @rule_bit_string = RandomBitString.new(@rule_size, :even)
    @input_bit_string = RandomBitString.new(@size, :even)
    @population = seed_rules
  end

  def run
    GENERATIONS.times do |i|
      puts "Generation #{i+1}"
      score_rules
      rank_rules
      print_rules
      breed_rules
    end
  end

private
  
  def seed_rules
    puts ' Seeding...'
    (0...SEED_SIZE).inject([]) { |rules, i| rules << generate_random_rule }
  end
  
  def score_rules
    puts ' Scoring...'
    @population.map!.with_index do |rule, i| 
      puts "  Rule #{i+1}"
      [rule.first, score_rule(rule.first)]
    end 
  end

  def score_rule(rule)
    output_set, results = [], []
    TEST_ITERATIONS.times do |i|
      input = generate_random_input
      input_check = INPUT_CHECK.call(input)
      output_check = OUTPUT_CHECKS[input_check]
      life = Automata.new(:dimensions => @dimensions, 
                      :size => @size, 
                      :reach => @reach, 
                      :rule => rule, 
                      :leap => 100,
                      :initial_state => input)
      output = life.run.to_s
      output_set << output
      results << output_check.call(output)
      # puts [input, output, input_check, results.last].inspect
    end
    
    # Remove cheaters
    if OUTPUT_SET_CHECK.call(output_set, @size)
      Rational(0,1)
    else
      Rational(results.count(true), TEST_ITERATIONS)
    end
  end

  def rank_rules
    puts ' Sorting...'
    @population.sort! { |(k1,v1), (k2,v2)| v2 <=> v1 }
  end

  def breed_rules
    puts ' Breeding...'
    rules = @population.map { |(rule, score)| rule }[0..SEED_SIZE/SELECTION_FACTOR]
    rule_pairs = rules.sort_by { rand}.repeated_permutation(2).sort_by { rand }
    
    offspring = []
    rule_pairs.take(SEED_SIZE - (SEED_SIZE/SELECTION_FACTOR)).each_with_index do |(r1, r2), i|
      puts "  Pair #{i+1}"
      offspring << r1 + r2
    end 
    @population = (rules + mutate_rules(offspring.flatten)).map { |r| wrap_rule(r) }
  end

  def mutate_rules(rules)
    rules.each { |rule| rule.mutate! }; rules
  end

  def print_rules
    @population.each { |r| puts "  #{r.first} (#{humanize(r.first)}) => #{r.last}" }
  end

  def generate_random_rule
    wrap_rule(Rule.new(@dimensions, @reach, @rule_bit_string.generate))
  end

  def generate_random_input
    @input_bit_string.generate
  end

  def wrap_rule(rule)
    [rule, 0]
  end

  def humanize(rule)
    rule.to_s.to_i(2).to_s(16)
  end


end
