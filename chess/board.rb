require_relative 'pieces.rb'

class Board

  attr_reader :grid

  def initialize(grid = nil)
    @grid = Array.new(8) { Array.new(8) }
  end

  def populate_grid
    self.grid[1].each_index{|i| self.grid[1][i] = Pawn.new(:black, self, [1,i])}
    self.grid[6].each_index{|i| self.grid[6][i] = Pawn.new(:white, self, [6,i])}

    self.grid[0][0], self.grid[0][7] = Rook.new(:black, self, [0,0]), Rook.new(:black, self, [0,7])
    self.grid[7][0], self.grid[7][7] = Rook.new(:white, self, [7,0]), Rook.new(:white, self, [7,7])
    self.grid[0][1], self.grid[0][6] = Knight.new(:black, self, [0,1]), Knight.new(:black, self, [0,6])
    self.grid[7][1], self.grid[7][6] = Knight.new(:white, self, [7,1]), Knight.new(:white, self, [7,6])
    self.grid[0][2], self.grid[0][5] = Bishop.new(:black, self, [0,2]), Bishop.new(:black, self, [0,5])
    self.grid[7][2], self.grid[7][5] = Bishop.new(:white, self, [7,2]), Bishop.new(:white, self, [7,5])
    self.grid[0][3], self.grid[7][3] = Queen.new(:black, self, [0,3]), Queen.new(:white, self, [7,3])
    self.grid[0][4], self.grid[7][4] = King.new(:black, self, [0,4]), King.new(:white, self, [7,4])
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
      # byebug
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

  protected

  attr_writer :grid
end
