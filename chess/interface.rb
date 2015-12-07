require 'colorize'
require_relative 'board.rb'
require_relative 'cursorable.rb'

class Interface

  include Cursorable

  SQUARE_COLOR = {
    :white => :green,
    :black => :red,
    :select => :yellow
  }

  PIECE_COLORS = {
    :white => :light_white,
    :black => :black
  }

  PIECES_SYMBOLS = {
    Pawn => " P  ",
    Rook => " R  ",
    Knight => " Kn ",
    Bishop => " B  ",
    Queen => " Q  ",
    King => " K  ",
    NilClass => "    "
  }

  attr_reader :board, :cursor_position

  def initialize(board)
    @board = board
    @cursor_position = [6, 5]
  end

  def display

    display_grid = []

    board.grid.each_with_index do |row, idx|
      display_grid << Array.new
      row.each_with_index do |piece, col_idx|
        piece_symbol = PIECES_SYMBOLS[piece.class]
        background_color = (idx + col_idx) % 2 == 0 ? :white : :black
        background_color = :select if [idx, col_idx] == cursor_position
        background_color = SQUARE_COLOR[background_color]
        piece_color = piece ? PIECE_COLORS[piece.color] : :white
        display_grid[idx] << piece_symbol.colorize(:color => piece_color, :background => background_color)
      end
      display_grid[idx] = display_grid[idx].join
    end
    system("clear")
    puts display_grid
  end

  def foo_for_now

    until false
      display
      get_input
    end

  end

  def update_pos(diff)
    new_pos = [(@cursor_position[0] + diff[0]) % 8, (@cursor_position[1] + diff[1]) % 8]
    @cursor_position = new_pos
  end





end
