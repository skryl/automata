class Cell
  include RandomBitString::BitString

  ALIVE = 'X'
  DEAD  = ' '

  attr_reader :index, :neighbors

  def initialize(index, value)
    self.alive = value
    @new_state = value
    @index = index
    @neighbors = []
  end

  def alive=(alive)
    @alive = 
      case alive
      when 1, ON;  true
      when 0, OFF;  false
      else          !!alive 
      end
  end

  def new_state=(new_state)
    @new_state = new_state
  end

  def alive?; @alive; end
  def dead?; !@alive; end

  def transition!
    self.alive = @new_state
  end

  def to_s
    alive? ? ALIVE : DEAD
  end

end
