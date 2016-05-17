module Alpha
  Move = Struct.new(:from, :to, :piece, :target, :score) do
    include Comparable
    
    def <=>(other)
      other.score <=> score
    end
  end
  
  Root = Struct.new(:move, :mx, :score, :fen, :san, :check) do
    include Comparable
    def <=>(other)
      other.score <=> score
    end
    
    def to_h
      { from: from, to: to, piece: piece, target: target, 
        color: color, score: score, fen: fen, san: san, check: check }
    end
    
    def to_s
      "#{san}: #{color} #{piece} -> #{to}#{'(' + target + ')' if capture?}, rating: #{score}#{', (check)' if check}"
    end
    
    def from()     PP[SQ64[move.from]] end
    def to()       PP[SQ64[move.to]] end
    def piece()    PCS[move.piece] end
    def target()   PCS[move.target] end
    def capture?() move.target != EMPTY end
    def color()    CLR[mx] end
  end
end