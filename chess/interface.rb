require 'colorize'
require_relative 'board.rb'
require_relative 'cursorable.rb'
require_relative 'error_handling.rb'

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
    Pawn => " #{"\u265F".encode('utf-8')} ",
    Rook => " #{"\u265C".encode('utf-8')} ",
    Knight => " #{"\u265E".encode('utf-8')} ",
    Bishop => " #{"\u265D".encode('utf-8')} ",
    Queen => " #{"\u265B".encode('utf-8')} ",
    King => " #{"\u265A".encode('utf-8')} ",
    NilClass => "   "
  }

  attr_reader :board, :cursor_position
  attr_accessor :moving_piece

  def initialize(board)
    @board = board
    @cursor_position = [6, 5]
    @moving_piece = nil
  end

  def display(player_color, game_over=false)

    display_grid = []

    board.grid.each_with_index do |row, idx|
      display_grid << Array.new
      row.each_with_index do |piece, col_idx|
        piece_symbol = PIECES_SYMBOLS[piece.class]
        piece_symbol = PIECES_SYMBOLS[NilClass] if piece == moving_piece
        background_color = (idx + col_idx) % 2 == 0 ? :white : :black
        piece_color = piece ? PIECE_COLORS[piece.color] : :white
          if [idx, col_idx] == cursor_position
            background_color = :select
            piece_symbol = PIECES_SYMBOLS[moving_piece.class] if moving_piece
            piece_color = moving_piece ? PIECE_COLORS[moving_piece.color] : piece_color
          end
        background_color = SQUARE_COLOR[background_color]

        display_grid[idx] << piece_symbol.colorize(:color => piece_color, :background => background_color)
      end
      display_grid[idx] = display_grid[idx].join
    end
    system("clear")
    puts display_grid
    unless game_over
      puts "#{player_color.to_s.capitalize} to move."
      puts "In Check!".blink if board.in_check?(player_color)
    end
  end

  def get_new_position(player_color)
    new_pos = nil
    until new_pos
      display(player_color)
      new_pos = get_input
    end

    self.moving_piece = board[new_pos]

    new_pos
  end

  def update_pos(diff)
    new_pos = [(@cursor_position[0] + diff[0]) % 8, (@cursor_position[1] + diff[1]) % 8]
    @cursor_position = new_pos
  end

  def get_move(player_color)

    piece_position = get_new_position(player_color)
    piece_position = get_new_position(player_color) until board[piece_position]

    piece = board[piece_position]

    raise InvalidMoveError unless piece.color == player_color

    destination = get_new_position(player_color)
    self.moving_piece = nil

    [piece, destination] # the piece and where its moving to.
  end

end
