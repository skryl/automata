# Automata

Automata is a cellular automata simulator and evolution framework. The DSL
is still under development but the engine is fairly functional.

## Usage

Load the library

    require './automata'

To run the default configuration (Conway's Game of Life)

    Automata.new(:size => 50, :speed => 30).visual_run(100)

To run a custom CA rule

    a = Automata.new(:dimensions => 1, :reach => 3, :size => 100, :speed => 60, 
                     :rule => '011000010011010000000100000100001001010000000000
                               000000100000010000000000001100100001001110000000
                               00011011110000001101001010001010'
    )

    # run for 1000 iterations
    a.visual_run(1000)

Parameter definitions

  * :dimensions - dimensionality of the CA (eg. 1,2,3)
  * :reach      - number of neighbors in each direction whose state is used to
                  to determine the next state of each cell
  * :size       - length of the CA (eg. for a 50x50 CA length = 50)
  * :speed      - simulation speed (the higher the faster)
  * :rule       - determines the output state for each combination of neighbor states
