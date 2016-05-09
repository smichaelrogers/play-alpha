module Alpha
  Move = Struct.new(:from, :to, :piece, :target, :score)
  Root = Struct.new(:move, :color, :score) do
    include Comparable
    def <=>(other)
      other.score <=> score
    end
    
    def to_h
      { from: PP[SQ64[move.from]], to: PP[SQ64[move.to]], piece: move.piece, color: color, target: move.target, score: score }
    end
    
    def to_s
      "#{PP[SQ64[move.from]]}(#{PCS[move.piece]}) to #{PP[SQ64[move.to]]}(#{PCS[move.target]}), rating: #{score}"
    end
  end
  
  class Search
    attr_reader :data
    def log(msg)
      @data[:log] << msg << ''
    end
    
    def initialize(fen = INIT_FEN)
      @data = { log: [] }
      @mx = fen.split[1] == 'b' ? 1 : 0
      @mn = @mx ^ 1
      @squares, @colors = Array.new(120) { -1 }, Array.new(120) { -1 }
      SQ.each { |i| @squares[i], @colors[i] = EMPTY, EMPTY }
      @kings = [-1, -1]
      fen.split.first.split('/').map do |row| 
        row.chars.map { |sq| sq.ord < 57 ? %w(e) * sq.to_i : sq }
      end.flatten.each_with_index do |sq, i|
        piece, color = PIECES[1].index(sq.downcase), sq == 'e' ? EMPTY : sq == sq.downcase ? BLACK : WHITE
        @squares[SQ[i]], @colors[SQ[i]] = piece, color
        @kings[color] = SQ[i] if piece == K
      end
      if @squares.count { |i| i != EMPTY } > 1 && @kings.count(-1) == 0
        log("Successfully loaded position #{fen}")
        true
      else
        log("Could not load position #{fen}")
        @data[:result] = 'error'
        false
      end
    end


    def find_move(duration = 4.0)
      @moves = Array.new(MAXPLY) { [] }
      @history = Array.new(MAXPLY) { Array.new(6) { Array.new(120) { 0 } } }
      @ply, @height, @clock, @nodes = 0, 0, 0, 0
      @root = nil
      last_clock, last_nodes = 0, 0
      start = Time.now
      roots = generate_moves.map { |m| Root.new(m, @mx, -INF) }
      
      while Time.now < start + duration && @height < MAXPLY
        @height += 1
        roots.each do |r|
          next unless make(r.move)
          r.score = -alphabeta(-INF, INF, @height)
          unmake(r.move)
        end
        @clock = (Time.now - start).round(2)
        @root = roots.sort!.first
        node_diff, clock_diff = @nodes - last_nodes, @clock - last_clock
        log("Searched #{node_diff} nodes from height #{@height} in #{clock_diff.round(2)} seconds (#{
            (node_diff / clock_diff).round(2)}/sec), the current best move is #{@root.to_s}")
        last_nodes, last_clock = @nodes, @clock
      end
      
      if !@root
        log("Unable to find a move")
        @data[:result] = in_check? ? CLR[@mn] : 'draw'
        return
      end
      
      log("Completed search of #{@nodes} nodes in #{@clock.round(2)} seconds (#{(@nodes / @clock).round(2)}/sec), making move #{@root.to_s}")
      make(@root.move)
      @data[:move] = @root.to_h.merge({ fen: get_fen, san: get_san(@root.move, in_check?) })
      @data[:board] = {}.tap { |h| SQ.each_with_index { |sq, i| h[PP[i]] = { piece: @squares[sq], color: @colors[sq], moves: [] } } }
      mvs = []
      generate_moves.each do |m|
        next unless make(m)
        mvs << Root.new(m, @mn, -evaluate).to_h.merge({ fen: get_fen, san: get_san(m, in_check?) })
        unmake(m)
      end
      
      if mvs.empty?
        log("#{CLR[@mx]} has no moves")
        @data[:result] = in_check? ? CLR[@mn] : 'draw'
      else
        log("#{CLR[@mx]} has #{mvs.length} possible moves: #{mvs.map { |m| m[:san] }.join(', ')}")
        mvs.each { |m| @data[:board][m[:from]][:moves] << m }
        @data[:result] = 'none'
      end
    end

    def alphabeta(alpha, beta, depth)
      @nodes += 1
      depth += 1 if depth == 0 && in_check? && @ply < MAXPLY
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
    
    def each_move(from, piece, color)
      if piece == P
        to = from + DIR[color]
        [to + 1, to - 1].each { |n| yield(from, n, P, @squares[n]) if @colors[n] == color ^ 1 }
        return unless @colors[to] == EMPTY
        yield(from, to, P, EMPTY)
        yield(from, to + DIR[color], P, EMPTY) if @squares[to + DIR[color]] == EMPTY && !(40..80).cover?(from)
      else STEPS[piece].each do |step|
          to = from + step
          while @colors[to] == EMPTY
            yield(from, to, piece, EMPTY)
            break unless SLIDES[piece]
            to += step
          end
          yield(from, to, piece, @squares[to]) if @colors[to] == color ^ 1
        end
      end
    end
    
    def generate_moves
      @moves[@ply].clear.tap do |mvs|
        SQ.select { |sq| @colors[sq] == @mx }.each do |sq|
          each_move(sq, @squares[sq], @mx) do |from, to, piece, target|
            score = target == EMPTY ? @history[@ply][piece][to] : 200_000 + target - piece
            mvs << Move.new(from, to, piece, target, score).freeze
          end
        end
        mvs.sort_by! { |m| -m.score }
      end
      @moves[@ply]
    end
    
    def evaluate
      score = 0
      SQ.select { |sq| @colors[sq] != EMPTY }.each do |i|
        piece, color = @squares[i], @colors[i]
        score += (VAL[piece] + POS[piece][FLIP[color] * SQ64[i]]) * FLIP[color]
        each_move(i, piece, color) do |from, to, _, target|
          score += (MOB[piece] + ATK[target]) * FLIP[color]
          score += CENTER[SQ64[from]] * FLIP[color] if piece == P
        end
      end
      score * FLIP[@mx]
    end
    
    def make(m)
      @ply += 1
      @squares[m.from], @colors[m.from] = EMPTY, EMPTY
      @squares[m.to], @colors[m.to] = m.piece, @mx
      @kings[@mx] == m.to if m.piece == K
      @squares[m.to] == Q if m.piece == P && !(30..90).cover?(m.to)
      if in_check?
        swap! && unmake(m)
        return false
      end
      swap!
    end
    
    def unmake(m)
      swap!
      @ply -= 1
      @squares[m.from], @colors[m.from] = m.piece, @mx
      @squares[m.to], @colors[m.to] = m.target, m.target == EMPTY ? EMPTY : @mn
      @kings[@mx] = m.from if m.piece == K
    end
    
    def swap!
      @mx, @mn = @mn, @mx
      true
    end
    
    def in_check?
      k = @kings[@mx]
      8.times do |i|
        return true if @squares[k + STEP[i]] == N && @colors[k + STEP[i]] == @mn
        sq = k + OCTL[i]
        sq += OCTL[i] while @colors[sq] == EMPTY
        next unless @colors[sq] == @mn
        case @squares[sq]
        when Q then return true
        when B then return true if i < 4
        when R then return true if i > 3
        when P then return true if k + DIR[@mx] - 1 == sq || k + DIR[@mx] + 1 == sq
        when K then return true if sq - (k + OCTL[i]) == 0
        end
      end
      false
    end
    
    
    
    def get_san(m, check = false)
      san = ''
      if m.piece == P
        san << PP[SQ64[m.from]][0] if m.target != EMPTY
      else
        san << PIECES[0][m.piece]
      end
      san << 'x' if m.target != EMPTY
      san << PP[SQ64[m.to]]
      san << "=Q" if m.piece == P && !(30..90).cover?(m.to)
      san << '+' if check
      san
    end
    
    def get_fen
      rows = []
      (21..91).step(10) do |i|
        a = (i...(i + 8)).to_a
        until a.empty?
          e = a.take_while { |k| @colors[k] == EMPTY }.length
          rows << a.shift(e).length unless e == 0
          rows << PIECES[@colors[a.first]][@squares[a.first]] if a.first
          a.shift
        end
        rows << "/" unless i == 91
      end
      "#{rows.join} #{COLORS[@mx]}"
    end
    
    
    
    def render
      puts "\n\n   #{@nodes} nodes @ #{(@nodes.to_f / @clock).round(2)}/sec"
      puts "   #{evaluate} evaluation for #{COLORS[@mx]}\n\n"
      8.times { |i| puts "  #{SQ[(i*8), 8].map { |j| UNICODE[@colors[j] % 6][@squares[j]].center(3, ' ') }.join}" }
    end
    
  end
end