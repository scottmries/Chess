require 'byebug'
require_relative 'interface.rb'
require_relative 'error_handling.rb'
require_relative 'board.rb'
require_relative 'cursorable.rb'


class ChessGame

  attr_reader :board, :interface, :current_player
  attr_writer :board, :interface, :current_player

  def initialize
    @board = Board.new
    @interface = Interface.new(board)
    @current_player = :white
  end

  def play_game
    while true
      turn
    end
  rescue QuitGame
    puts "Bye Bye, quitter"
  end

  def switch_player
    self.current_player = (current_player == :white) ? :black : :white
  end

  def turn
    interface.display(current_player)
    piece, destination = interface.get_move(current_player)
    piece.move_to(destination)
    switch_player
  rescue InvalidMoveError
    retry
  end

end
