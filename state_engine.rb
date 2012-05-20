class StateEngine
  extend  Forwardable
  include ManyParams
  include RandomBitString::BitString

  attr_reader      :norm_size, :transition_map
  def_delegators   :@rule, :reach, :reach_range, :norm_reach_range
  init_params      :dimensions, :size, :rule, :continuous
  validated_params :dimensions, :reach, :rule

  def initialize(params = {})
    parse_init_params(params)

    @length, @area, @volume = @size, @size ** 2, @size ** 3
    @norm_size = @size ** @dimensions

    return unless valid_params?
    @transition_map = init_transition_map
  end

  def parse(state)
    construct_cell_grid(state)
  end

  def next!(grid)
    iterate_cell_grid!(grid)
  end

private

# Initialization

  def init_transition_map
    (0...2**(norm_reach_range)).inject({}) do |h,i| 
      permutation = i.to_s(2).rjust(norm_reach_range,'0') 
      h[permutation] = @rule[i]; h 
    end
  end

  
# Grid construction

  # 1.9 only
  # def construct_cell_grid(state)
    # connect_neighbor_cells!(
    #   state.split('').map.with_index { |v, i| Cell.new(i, v) } )
  # end
  
  def construct_cell_grid(state)
    grid = []
    state.split('').each_with_index { |v,i| grid << Cell.new(i,v) }
    connect_neighbor_cells!(grid)
  end
  

  def connect_neighbor_cells!(cells)
    cells.each do |c|
      reach_group = find_reachable_indeces(cells, c.index)
      reach_group.each do |neighbor_index| 
        c.neighbors << find_neighbor(cells, neighbor_index)
      end
    end
  end

  def find_reachable_indeces(cells, index)
    relative_reach_range = (-reach..reach).to_a

    one_d_indeces = \
      relative_reach_range.map do |ri| 
        ni = index + ri
        @continuous ? (@length * (index/@length)) + (ni % @length) : ni
      end
    return one_d_indeces if one_d?

    two_d_indeces = \
      one_d_indeces.map do |i|
        relative_reach_range.map do |ri| 
          ni = i + ri * @length
          @continuous ? (@area * (index/@area)) + (ni % @area) : ni
        end
      end.flatten
    return two_d_indeces if two_d?

    return \
      two_d_indeces.map do |i|
        relative_reach_range.map do |ri| 
          ni = i + ri * @area
          @continuous ? (@volume * (index/@volume)) + (ni % @volume) : ni
        end
      end.flatten
  end

  def find_neighbor(cells, index)
    (index < 0 || index >= @norm_size) ? nil : cells[index]
  end

# Iteration

  def iterate_cell_grid!(cells)
    cells.each do |c|
      c.new_state = \
        @transition_map[collect_neighbor_states(c).join('')]
    end
    cells.each { |c| c.transition! }
  end
  

  def collect_neighbor_states(cell)
    cell.neighbors.map { |n| (n && n.alive?) ? ON : OFF }
  end
  
# Validation

  def valid_dimensions?
    (1..3).include?(@dimensions)
  end

  # Reach must be less than half the length because it is multiplied by 2 to
  # calculate the total reach range which must be <= length
  #
  def valid_reach?
    reach_range <= @length
  end

  def valid_rule?
    @rule.valid_params?
  end

# Helpers

  def one_d?;   @dimensions == 1 end
  def two_d?;   @dimensions == 2 end
  def three_d?; @dimensions == 3 end

end
