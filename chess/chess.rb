require 'byebug'
require_relative 'interface.rb'
require_relative 'error_handling.rb'
require_relative 'board.rb'
require_relative 'cursorable.rb'


class ChessGame

  attr_reader :board, :interface
  attr_writer :board, :interface

  def initialize
    @board = Board.new
    @interface = Interface.new(board)
  end

  def play_game
    while true
      turn
    end
  end

  def turn
    interface.display
    piece, destination = interface.get_move
    piece.move_to(destination)
  rescue InvalidMoveError
    retry
  end

end
