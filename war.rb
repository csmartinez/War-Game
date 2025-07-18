class Deck
    SUITS = %w[Hearts Diamonds Clubs Spades]
    RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A]

    def self.standard_deck
        SUITS.product(RANKS).map { |suit, rank| "#{rank} of #{suit}" }
    end

    def self.deal(players_count)
        deck = standard_deck.shuffle
        hand_size = deck.size / players_count
        deck.each_slice(hand_size).first(players_count)
    end
end

class War < Deck
    attr_reader :players, :hands

    def initialize(players_count = 2)
        raise ArgumentError, 'Players must be 2 or 4' unless [2, 4].include?(players_count)
        @players = Array.new(players_count) { |player_index| "Player #{player_index + 1}" }
        @hands = Deck.deal(players_count)
    end

    def active_players
        @players.each_with_index.select { |_, hand_index| @hands[hand_index].any? }.map(&:first)
    end

    def winner
        winning_hand_index = @hands.find_index { |hand| hand.size == 52 }
        winning_hand_index ? @players[winning_hand_index] : nil
    end

    def play
        in_play_indices = @hands.each_index.select { |hand_index| @hands[hand_index].any? }
        return if in_play_indices.size <= 1
        pile = Array.new(@players.size) { [] }
        war_indices = in_play_indices.dup

        loop do
            face_up_cards = reveal_face_up_cards(war_indices, pile)
            war_indices = war_indices.select { |hand_index| pile[hand_index].any? }
            break if war_indices.empty?

            top_indices, _ = top_players(face_up_cards)
            puts "Cards played: " + face_up_cards.map { |hand_index, card| "#{@players[hand_index]}: #{card}" }.join(", ")

            if top_indices.size == 1
                collect_won_cards(top_indices.first, pile)
                break
            else
                puts "War! Players: #{top_indices.map { |hand_index| @players[hand_index] }.join(", ")}" 
                war_indices = top_indices
                add_down_cards(war_indices, pile)
                break if war_indices.all? { |hand_index| @hands[hand_index].empty? }
            end
        end
        eliminate_players
    end

    private

    def reveal_face_up_cards(indices, pile)
        indices.map do |hand_index|
            next unless @hands[hand_index].any?
            pile[hand_index] << @hands[hand_index].shift
            [hand_index, pile[hand_index].last]
        end.compact
    end

    def top_players(face_up_cards)
        values = face_up_cards.map { |hand_index, card| [hand_index, Deck::RANKS.index(card.split.first)] }
        max_value = values.map { |_, rank_index| rank_index }.max
        top_indices = values.select { |_, rank_index| rank_index == max_value }.map(&:first)
        [top_indices, max_value]
    end

    def add_down_cards(indices, pile)
        indices.each do |hand_index|
            3.times do
                break if @hands[hand_index].empty?
                pile[hand_index] << @hands[hand_index].shift
            end
        end
    end

    def collect_won_cards(winner_index, pile)
        won_cards = pile.flatten.compact.shuffle
        @hands[winner_index].concat(won_cards)
        puts "#{@players[winner_index]} wins the round and takes #{won_cards.size} cards."
    end

    def eliminate_players
        @hands.each_with_index { |hand, hand_index| @hands[hand_index] = [] if hand.empty? }
    end
end

if __FILE__ == $0
    puts "========================"
    puts "Renew Financial Code Challenge Submission by Carli Martinez 7/19/25"
    puts "========================"
    puts "Are you ready? It's time to play Who Wants to be a Millio- Oops, wrong game! This is War! \n\n"
    print 'Enter number of players (2 or 4): '
    players_count = gets.to_i
    unless [2, 4].include?(players_count)
        puts 'Invalid number of players.'
        exit 1
    end
    game = War.new(players_count)
    round_num = 1
    print 'Let the game begin!'
    until game.winner || game.hands.count { |hand| hand.any? } <= 1
        puts "\n--- Round #{round_num} ---"
        game.players.each_with_index do |player, hand_index|
            puts game.hands[hand_index].any? ? "#{player}: #{game.hands[hand_index].size} cards" : "#{player}: eliminated"
        end
        game.play
        round_num += 1
        sleep 0.5
    end
    winner = game.winner || game.active_players.first
    puts "\nGame over! The winner is: #{winner}!"
end
