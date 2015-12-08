class Piece

  DIAGONALS = [
    [1, 1],
    [1, -1],
    [-1, 1],
    [-1, -1]
  ]

  NONDIAGONALS = [
    [1, 0],
    [-1, 0],
    [0, 1],
    [0, -1]
  ]

  KNIGHTS = [
    [-1, 2],
    [1, 2],
    [-1, -2],
    [1, -2],
    [2,1],
    [2,-1],
    [-2,1],
    [-2,-1]
  ]

  attr_reader :color, :board, :position

  def initialize(color, board, position)
    @board = board
    @color = color
    @position = position
  end

  def moves
    []
  end

  def in_bounds?(pos)
    pos.all? { |coord| (0..7).include?(coord) }
  end

  def vec_add(position, relative_position)
    pairs= position.zip(relative_position)
    pairs.map{|pair| pair[0] + pair[1]}
  end

  def opponent_color
    (self.color == :white) ? :black : :white
  end

  def valid_moves
    moves.reject { |move| subjunctive(move).in_check?(color) }
  end

  def move_to(destination)
    unless valid_moves.include?(destination)
      raise InvalidMoveError
    end
    unsafe_move_to(destination)
  end

  def unsafe_move_to(destination)
    self.board[position] = nil
    self.board[destination] = self
    self.position = destination
  end

  def threatens
    moves
  end

  def subjunctive_moves
    moves.map { |move| self.subjunctive(move) }
  end

  def subjunctive(move)
    new_board = board.dup
    new_board[self.position].unsafe_move_to(move)
    new_board
  end

  def inspect
    "#{self.color.to_s.capitalize} #{self.class.name} at #{self.position}"
  end

  def duplicate(board)
    new_piece = self.dup
    new_piece.board = board
    new_piece
  end


  attr_writer :board

  attr_writer :position

end



class SlidingPiece < Piece

  attr_reader :directions

  def moves
    moves = []
    self.directions.each do |direction|
      blocked = false
      move = vec_add(position, direction)
      until blocked
        if not in_bounds?(move)
          blocked = true
        elsif board.piece_color(move) == self.color
          blocked = true
        elsif board.piece_color(move).nil?
          moves << move.dup
          move = vec_add(move, direction)
        else
          blocked = true
          moves << move
        end
      end
    end

    moves
  end
end

class JumpingPiece < Piece

  attr_reader :rel_moves
  def moves
    moves = rel_moves.map { |rel_move| vec_add(position, rel_move) }
    moves.select { |move| in_bounds?(move) && board.piece_color(move) != self.color }
  end

end

#This assumes that the class has an instance variable has_moved that initializes to false.

module Castleable

  attr_reader :has_moved

  def unsafe_move_to(destination)
    unless castle(destination)
      super
      self.has_moved = true
    end
  end

  def has_moved?
    has_moved
  end

  attr_writer :has_moved

end


class Pawn < Piece

  def initialize(board, color, position)
    super
    @has_moved = false
  end

  def has_moved?
    @has_moved
  end

  def direction
    self.color == :white ? -1 : 1
  end

  def moves
    moves = []

    moves << vec_add(position, [direction, 0])
    unless has_moved?
      moves << vec_add(position, [2 * direction, 0])
    end

    captures = [vec_add(position, [direction, -1]), vec_add(position, [direction, 1])]

    captures = captures.select{|capture| in_bounds?(capture) && board.piece_color(capture) == opponent_color}
    moves = moves.select{|move| in_bounds?(move) && board[move].nil?}
    captures + moves
  end

  def move_to(destination)
    super
    @has_moved = true
  end

  def threatens
    [vec_add(position, [direction, -1]), vec_add(position, [direction, 1])]
  end

end

class Rook < SlidingPiece

  include Castleable

  def initialize(board, color, position)
    super
    @directions = Piece::NONDIAGONALS
    @has_moved = false
  end

  def castle(destination)
    false
  end
end

class Knight < JumpingPiece

  def initialize(board, color, position)
    super
    @rel_moves = Piece::KNIGHTS
  end

end

class Bishop < SlidingPiece

  def initialize(board, color, position)
    super
    @directions = Piece::DIAGONALS
  end

end


class Queen < SlidingPiece

  def initialize(board, color, position)
    super
    @directions = Piece::DIAGONALS + Piece::NONDIAGONALS
  end
end

class King < JumpingPiece

  include Castleable

  def initialize(board, color, position)
    super
    @rel_moves = Piece::DIAGONALS + Piece::NONDIAGONALS
    @has_moved = false

  end

  def moves(castle_possible = true)
    moves = super()
    if castle_possible
      moves << [rank, 2] if castle_left?
      moves << [rank, 6] if castle_right?
    end
    moves
  end

  def threatens
    moves(false)
  end

  def left_rook
    board[[rank, 0]]
  end

  def right_rook
    board[[rank, 7]]
  end

  def rank
    position.first
  end

  def castle_left!
    king_pos = [rank, 2]
    rook_pos = [rank, 3]
    castle!(king_pos, rook_pos, left_rook)
  end

  def castle_right!
    king_pos = [rank, 6]
    rook_pos = [rank, 5]
    castle!(king_pos, rook_pos, right_rook)
  end

  def castle!(king_pos, rook_pos, rook)
    self.board[king_pos] = self
    self.board[rook_pos] = rook
    self.board[self.position] = nil
    self.board[rook.position] = nil
    rook.position = rook_pos
    self.position = king_pos
    self.has_moved = true
    rook.has_moved = true
  end

  def castle_left?
    if left_rook.is_a?(Rook) && !left_rook.has_moved?
      want_not_threatened = [[rank, 2], [rank, 3]]
      want_empty = [[rank, 1], [rank, 2], [rank, 3]]
      return clear_path_and_no_check?(want_not_threatened, want_empty)
    end
    false
  end

  def castle_right?
    if right_rook.is_a?(Rook) && !right_rook.has_moved?
      want_not_threatened = [[rank, 5], [rank, 6]]
      want_empty = want_not_threatened
      return clear_path_and_no_check?(want_not_threatened, want_empty)
    end
    false
  end

  def clear_path_and_no_check?(want_not_threatened, want_empty)
    no_check = want_not_threatened.none? { |position| board.castle_threatened_to_check?(position, opponent_color)}
    clear_path = want_empty.all?{ |position| board[position].nil?}

    no_check && clear_path
  end

  def castle(destination)
      unless has_moved
        castle_left! if destination[1] == 2
        castle_right! if destination[1] == 6
      end
  end




end
