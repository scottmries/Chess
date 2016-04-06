require_relative 'pieces.rb'

class Board

  attr_accessor :grid

  def initialize(grid = nil)
    @grid = Array.new(8) { Array.new(8) }
  end

  def populate_grid
    piece_kinds = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    piece_kinds.each_with_index do |piece_kind, column_idx|
      {black: {0: piece, 1: Pawn}, white: {7: piece, 6: Pawn}}.each do |color, row_type|
        row_type.each do |row, type|
          self.grid[row][column_idx] = type.new(color, self, [row, column_idx])
        end
      end
    end
  end

  def [](pos)
    x,y = pos
    grid[x][y]
  end

  def []=(pos, item)
    x,y = pos
    self.grid[x][y] = item
  end

  def piece_color(pos)
    square_contents = self[pos]
    return square_contents.color if square_contents.is_a?(Piece)
    nil
  end

  def threatened?(piece)
    threatened_position?(piece.position, piece.opponent_color)
  end

  def threatened_position?(position, evil_color)
    pieces(evil_color).each do |evil_piece|
      threatened_positions = evil_piece.threatens
      threatened_positions.each do |threatened_position|
        return true if threatened_position == position
      end
    end
    false
  end

    def castle_threatened_to_check?(position, evil_color)
      pieces = pieces(evil_color).reject { |piece| piece.is_a?(King) && !piece.has_moved }
      pieces.each_with_index do |evil_piece|
        evil_piece.threatens.each do |threatened_position|
          return true if threatened_position == position
        end
      end
      false
    end

  def the_king(color)
    piece_arr = pieces(color)
    piece_arr.find {|piece| piece.is_a?(King)}
  end

  def in_check?(color)
    threatened?(the_king(color))
  end

  def pieces(color)
    pieces = []
    grid.each_with_index do |row, r_idx|
      row.each_with_index do |square, c_idx|
        pieces << square if square && square.color == color
      end
    end

    pieces
  end

  def no_moves_left?(color)
    parallel_universes = pieces(color).flat_map { |piece| piece.subjunctive_moves}
    parallel_universes.all? { |universe| universe.in_check?(color)}
  end

  def in_stalemate?(color)
    no_moves_left?(color) && !in_check?(color)
  end

  def in_checkmate?(color)
    no_moves_left?(color) && in_check?(color)
  end

  def dup
    new_board = Board.new

    new_board.grid.each_with_index do |row, i|
      row.each_index do |j|
        if grid[i][j]
          new_board[[i,j]] = grid[i][j].duplicate(new_board)
        else new_board[[i,j]] = nil
        end
      end
    end

    new_board
  end
end
