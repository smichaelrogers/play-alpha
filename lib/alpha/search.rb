module Alpha
  
  class Search
    
    def initialize
      @log = []
    end
    
    def find_move(duration: 2.0)
      @nodes, @height, @clock, @ply = 0, 1, 0, 0
      @result = 'none'
      lc, ln = 0, 0
      @check = in_check?(@mx)
      
      unless generate_roots
        @result = @check ? CLR[@mn] : 'draw'
        return
      end
      
      start = Time.now
      
      while @clock < duration && @height < MAXPLY
        @height += 1
        
        @roots.each do |r|
          make(r.move)
          r.score = -alphabeta(-INF, INF, @height)
          unmake(r.move)
        end
        
        @clock = (Time.now - start).round(2)
        @root = @roots.sort!.first
        @log << "> Searched #{@nodes - ln} nodes from height #{@height} @ #{
                ((@nodes - ln).to_f/(@clock - lc)).round(2)}/s, current move: #{@root.to_s}"
        lc, ln = @clock, @nodes
      end

      @log << "" << "Making move: #{@root.to_s}"
      make(@root.move)
      @fen, @check, @board = @root.fen, @root.check, {}
      PP.each_with_index { |sq, i| @board[sq] = { piece: @squares[SQ[i]], color: @colors[SQ[i]], moves: [] } }
      if generate_roots
        @roots.each { |r| @board[r.from][:moves] << r.to_h }
        @log << "" << "Black has #{@roots.length} possible moves: #{@roots.map { |r| r.san }.join(', ')}"
      else
        @result = @check ? CLR[@mn] : 'draw'
      end
      true
    end
    
    def generate_roots
      @history = Array.new(MAXPLY) { Array.new(6) { Array.new(120) { 0 } } }
      @moves = Array.new(MAXPLY) { [] }
      @roots = []
      generate_moves.each do |m|
        next unless make(m)
        @roots << Root.new(m.dup, @mn, -evaluate, get_fen, get_san(m)).tap do |r| 
          r.check = in_check?(@mx)
          r.san += '+' if r.check
        end
        unmake(m)
      end
      @roots.any?
    end
    

    def alphabeta(alpha, beta, depth)
      @nodes += 1
      return evaluate if depth == 0
      generate_moves.each do |m|
        next unless make(m)
        x = -alphabeta(-beta, -alpha, depth - 1)
        unmake(m)
        if x > alpha
          @history[@ply][m.piece][m.to] += (depth + 1) * @height if m.target == EMPTY
          return beta if x >= beta
          alpha = x
        end
      end
      alpha
    end


    def each_move(from)
      piece, color = @squares[from], @colors[from]
      if piece == P
        to = from + DIR[color]
        yield(to - 1, P, @squares[to - 1]) if @colors[to - 1] == color ^ 1
        yield(to + 1, P, @squares[to + 1]) if @colors[to + 1] == color ^ 1
        return unless @colors[to] == EMPTY
        yield(to, P, EMPTY)
        to += DIR[color]
        yield(to, P, EMPTY) if @squares[to] == EMPTY && !(40..80).cover?(from)
      
      else STEPS[piece].each do |step|
          to = from + step
          while @colors[to] == EMPTY
            yield(to, piece, EMPTY)
            break unless SLIDES[piece]
            to += step
          end
          yield(to, piece, @squares[to]) if @colors[to] == color ^ 1
        end
      end
    end
    
    
    def generate_moves
      @moves[@ply].clear
      SQ.select { |sq| @colors[sq] == @mx }.each do |from|
        each_move(from) do |to, piece, target|
          score = target == EMPTY ? @history[@ply][piece][to] : 200_000 + target - piece
          @moves[@ply] << Move.new(from, to, piece, target, score).freeze
        end
      end
      @moves[@ply].sort_by! { |m| -m.score }
    end
    
    
    def evaluate
      score = 0
      SQ.select { |sq| @colors[sq] != EMPTY }.each do |from|
        score += (VAL[@squares[from]] + POS[@squares[from]][FLIP[@colors[from]] * SQ64[from]]) * FLIP[@colors[from]]
        each_move(from) do |to, piece, target|
          score += (MOB[piece] + ATK[target] + (piece == P ? CENTER[SQ64[from]] : 0)) * FLIP[@colors[from]]
        end
      end
      score * FLIP[@mx]
    end


    def make(m)
      @ply += 1
      @squares[m.to], @colors[m.to] = m.piece, @mx
      @squares[m.from], @colors[m.from] = EMPTY, EMPTY
      @squares[m.to] = Q if m.piece == P && !(30..90).cover?(m.to)
      @kings[@mx] = m.to if m.piece == K
      
      @mx, @mn = @mn, @mx
      if in_check?(@mn)
        unmake(m)
        return false
      end
      true
    end
    
    
    def unmake(m)
      @ply -= 1
      @mx, @mn = @mn, @mx
      @colors[m.from], @squares[m.from] = @mx, m.piece
      @kings[@mx] = m.from if m.piece == K
      if m.target == EMPTY
        @colors[m.to], @squares[m.to] = EMPTY, EMPTY
      else
        @colors[m.to], @squares[m.to] = @mn, m.target
      end
    end

    def in_check?(c)
      OCTL.each_with_index do |step, i|
        if @squares[@kings[c] + STEP[i]] == N
          return true if @colors[@kings[c] + STEP[i]] == c ^ 1
        end
        sq = @kings[c] + step
        sq += step until @colors[sq] != EMPTY
        next unless @colors[sq] == c ^ 1
        case @squares[sq]
        when Q then return true
        when B then return true if i < 4
        when R then return true if i > 3
        when P then return true if (@kings[c] + DIR[c] - sq).abs == 1
        when K then return true if @kings[c] + step == sq
        else next end
      end
      false
    end
  
    
  end
end
