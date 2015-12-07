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

  attr_reader :color, :board

  def initialize(color, board)
    @board = board
    @color = color
    @position = nil
  end

  def moves
    []
  end

  def position
    return @position if !@position.nil? && board[@position] == self

    board.grid.each_with_index do |row, i|
      row.each_with_index do |piece, j|
        return @position = [i,j] if piece == self
      end
    end

    nil
  end

  def in_bounds?(pos)
    pos.all? { |coord| (0..7).include?(coord) }
  end

  def vec_add(position, relative_position)
    position.each_index { |i| position[i] += relative_position[i] }
  end

  def opponent_color
    (self.color == :white) ? :black : :white
  end

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

class Pawn < Piece

  def initialize(board, color)
    super
    @has_moved = false
  end

  def has_moved?
    @has_moved
  end

  def moves
    moves = []
    direction = self.color == :white ? -1 : 1

    moves << vec_add(position, [direction, 0])
    unless has_moved?
      moves << vec_add(position, [2 * direction, 0])
    end

    captures = [vec_add(position, [direction, -1]), vec_add(position, [direction, 1])]

    captures = captures.select{|capture| in_bounds?(capture) && board.piece_color(capture) == opponent_color}
    moves = moves.select{|move| in_bounds?(move) && board[move].nil?}
    captures + moves
  end

end

class Rook < SlidingPiece

  def initialize(board, color)
    super
    @directions = Piece::NONDIAGONALS
  end
end

class Knight < JumpingPiece

  def initialize(board, color)
    super
    @rel_moves = Piece::KNIGHTS
  end

end

class Bishop < SlidingPiece

  def initialize(board, color)
    super
    @directions = Piece::DIAGONALS
  end

end


class Queen < SlidingPiece

  def initialize(board, color)
    super
    @directions = Piece::DIAGONALS + Piece::NONDIAGONALS
  end
end

class King < JumpingPiece

  def initialize(board, color)
    super
    @rel_moves = Piece::DIAGONALS + Piece::NONDIAGONALS
  end

end
