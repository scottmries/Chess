require 'byebug'
require_relative 'interface.rb'
require_relative 'error_handling.rb'
require_relative 'board.rb'
require_relative 'cursorable.rb'


class ChessGame

  attr_reader :board, :interface, :current_player, :checkmate, :stalemate
  attr_writer :board, :interface, :current_player, :checkmate, :stalemate

  def initialize
    @board = Board.new
    @board.populate_grid
    @interface = Interface.new(board)
    @current_player = :white
    @checkmate = false
    @stalemate = false
  end

  def play_game
    until checkmate || stalemate
      turn
      self.checkmate = board.in_checkmate?(current_player)
      self.stalemate = board.in_stalemate?(current_player)
    end
    interface.display(current_player, true)
    puts "Checkmate!\nThe game is over and #{current_player.to_s.capitalize} lost!" if checkmate
    puts "It's a draw!" if stalemate
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
