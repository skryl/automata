class RandomBitString

  module BitString
    ON, OFF           = '1', '0'
    FORMAT            = /\A[10]*\Z/
  end
  include BitString

  GAUSSIAN_SQUEEZE  = 20
  TEST_DIST_SIZE    = 100000
  POWER_SKEW        = 2

  def initialize(length, dist = :even)
    @length, @dist = length, dist
    @bitstring = generate
  end
  
  def generate
    generate_bit_vector(@length, @dist)
  end

  def to_s
    @bitstring
  end

  def print_distribution
    generate_test_distribution.each do |(k,v)| puts "#{k} -> #{v}" end
  end

  def self.dehumanize(string)
    string.gsub(/[^01]/,'')
  end

private

  # TODO: add random clustering
  def generate_bit_vector(length, dist)
    num_ones = send("rand_#{dist}", length)
    bitvector = ([ON] * num_ones) + ([OFF] * (length - num_ones))
    bitvector.shuffle.join
  end

  # Even distribution
  def rand_even(max)
    rand(max)
  end

  # Power distribution
  def rand_power(max)
    max - 1 - (((max**(POWER_SKEW + 1)) * rand)**(1.0 / (POWER_SKEW + 1))).to_i
  end

  # Gaussian distribution
  def rand_gaussian(max)
    r, w = 0.0/0.0, 0.0
    mean = max/2
    stddev = (max/(GAUSSIAN_SQUEEZE*2))

    until r >= -GAUSSIAN_SQUEEZE && r <= GAUSSIAN_SQUEEZE
      until w > 0.0 && w < 1.0
        x1 = 2.0 * rand - 1.0
        x2 = 2.0 * rand - 1.0
        w = ( x1 * x2 ) + ( x2 * x2 )
      end

    w = Math.sqrt( -2.0 * Math.log( w ) / w )
    r = x1 * w
    end

    [(mean + r * stddev).to_i.abs, max].min
  end

  def generate_test_distribution
    sample = (0...TEST_DIST_SIZE).inject([]) do |a, i| a << random_bit_string(100) end
    dist = sample.inject({}) do |h, s| count = s.count(ON); h[count] = (h[count] || 0) + 1; h end
    dist.sort do |(k1,v1),(k2,v2)| k1 <=> k2 end
  end

end

