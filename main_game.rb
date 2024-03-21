require 'yaml'
MESSAGES = YAML.load_file('messages.yml')
GAMES_TO_WIN = 3

module Board
  def move_history_board(h_name, h_moves, c_name, c_moves)
    line_size = ([h_name.size, c_name.size].max * 2) + 4
    board_name = "ATTACK HISTORY"
    line_detail = "_" * (line_size / 2)
    board(h_name, c_name, board_name, line_size)
    move_history_board_moves(h_moves, c_moves, line_size)
    prompt "|" + line_detail + "|" + line_detail + "|"
  end

  def board(h_name, c_name, board_name, line_size)
    line_detail = "-" * (line_size / 2)
    format_board_lines(board_name, line_size, line_detail, h_name, c_name)
  end

  def scoreboard(h_name, h_score, c_name, c_score)
    line_size = ([h_name.size, c_name.size].max * 2) + 4
    brd_name = "SCOREBOARD"
    line_detail = "_" * (line_size / 2)
    h = h_score.to_s
    c = c_score.to_s
    board(h_name, c_name, brd_name, line_size)
    prompt "|#{h.center(line_size / 2, ' ')}|#{c.center(line_size / 2, ' ')}|"
    prompt "|#{line_detail}|#{line_detail}|"
  end

  private

  def line_setup(name, line_size)
    name.center(line_size / 2, ' ')
  end

  def format_board_lines(board_name, line_size, line_detail, h_name, c_name)
    prompt "_" * (line_size + 2)
    prompt "|#{board_name.center(line_size, ' ')} |"
    prompt "|#{'-' * (line_size / 2)}+#{'-' * (line_size / 2)}|"
    prompt "|#{line_setup(h_name, line_size)}|#{line_setup(c_name, line_size)}|"
    prompt "|#{line_detail}+#{line_detail}|"
  end

  def move_history_board_moves(h_moves, c_moves, line_size)
    h = h_moves.flatten
    c = c_moves.flatten
    l = line_size / 2
    h_moves.flatten.each_index do |idx|
      prompt "|#{h[idx].to_s.center(l, ' ')}|#{c[idx].to_s.center(l, ' ')}|"
    end
  end
end

module Displayable
  def message
    MESSAGES
  end

  def prompt(msg)
    puts msg
  end

  def transition(n)
    sleep(n)
    system("clear")
  end

  def display_welcome_message
    prompt message['intro1']
    return if !skip_intro?
    system("clear")
    prompt message['intro2']
    transition(2.5)
    prompt message['intro3']
    enter_to_continue
  end

  def display_rules
    prompt message['rules']
    prompt "First to #{GAMES_TO_WIN} successful attacks wins the battle!"
  end

  def display_moves
    prompt "#{human.name} chose #{human.move}."
    sleep(1.5)
    prompt "#{computer.name} chose #{computer.move}."
    transition(2)
  end

  def display_winner
    if human.move > computer.move
      prompt "#{human.name}'s attack is successful!"
    elsif human.move < computer.move
      prompt "#{computer.name}'s attack is successful!"
    else
      prompt "It's a draw!"
    end
    transition(2)
  end

  def display_score
    scoreboard(human.name, human.score, computer.name, computer.score)
    transition(3)
  end

  def display_overall_winner
    if human.score == computer.score
      prompt "This battle is a draw."
      prompt "You and #{computer.name} are evenly matched!"
      transition(5)
    else
      human.score == GAMES_TO_WIN ? human_victory : computer_victory
    end
  end

  def display_move_history
    h_name = human.name
    h_moves = human.move_history.values
    c_name = computer.name
    c_moves = computer.move_history.values
    move_history_board(h_name, h_moves, c_name, c_moves)
  end

  def display_goodbye_message
    prompt "Until we meet again, may the Force be with you."
  end

  private

  def enter_to_continue
    prompt "(Press ENTER to continue.)"
    gets.chomp.downcase
    system("clear")
  end

  def human_victory
    prompt "#{human.name} IS VICTORIOUS!"
    transition(2)
  end

  def computer_victory
    prompt "#{computer.name} IS VICTORIOUS!"
    transition(2)
  end

  def skip_intro?
    answer = gets.chomp.downcase
    answer.empty?
  end
end

class Move
  attr_reader :value

  def initialize(value)
    @value = value
  end

  VALUES = %w(rock paper scissors lizard spock r p x l s)

  WINNING_MOVES = { 'rock' => ['scissors', 'lizard'],
                    'paper' => ['rock', 'spock'],
                    'scissors' => ['paper', 'lizard'],
                    'lizard' => ['spock', 'paper'],
                    'spock' => ['scissors', 'rock'] }

  def >(other_move)
    WINNING_MOVES[value].include?(other_move)
  end

  def <(other_move)
    WINNING_MOVES[other_move].include?(value)
  end

  def to_s
    @value
  end
end

class Player
  include Displayable

  attr_accessor :move, :name, :score, :move_history

  def initialize
    set_name
    @score = 0
    @move_history = {}
  end

  def track_move
    if move_history.keys.include?(name)
      move_history[name] += [move]
    else
      move_history[name] = [move]
    end
  end
end

class Human < Player
  def set_name
    n = ''
    prompt "What is your name?"
    loop do
      n = gets.chomp
      system("clear")
      break unless n.empty? || n.squeeze == ' '
      prompt "Please enter a name."
    end
    self.name = n.upcase
    system("clear")
  end

  def get_choice(input)
    case input
    when 'r' then 'rock'
    when 'p' then 'paper'
    when 'x' then 'scissors'
    when 'l' then 'lizard'
    when 's' then 'spock'
    else input
    end
  end

  def choose_move
    choice = nil
    loop do
      display_rules
      prompt "Choose your move..."
      choice = get_choice(gets.chomp.downcase)
      break if Move::VALUES.include?(choice)
      system("clear")
      prompt "Try again, young padawan."
    end
    choice
  end

  def choose
    choice = choose_move
    self.move = Move.new(choice)
    track_move
    system("clear")
  end
end

class Computer < Player
  TYRANUS_MOVES = ['rock']
  MAUL_MOVES = ['rock', 'paper', 'scissors', 'lizard', 'spock']
  VADER_MOVES = ['scissors', 'scissors', 'scissors', 'rock', 'lizard', 'spock']
  SIDIOUS_MOVES = ['lizard', 'spock']
  ROBOT_MOVES = { 'DARTH TYRANUS' => TYRANUS_MOVES,
                  'DARTH MAUL' => MAUL_MOVES,
                  'DARTH VADER' => VADER_MOVES,
                  'DARTH SIDIOUS' => SIDIOUS_MOVES }

  def set_name
    system("clear")
    self.name = want_to_choose? ? choose_opponent : ROBOT_MOVES.keys.sample
    system("clear")
    prompt "Your opponent has been chosen. #{name} approaches!"
    transition(2.5)
  end

  def opponent_choices(answer)
    case answer
    when 'a' then "DARTH TYRANUS"
    when 'b' then "DARTH MAUL"
    when 'c' then "DARTH VADER"
    when 'd' then "DARTH SIDIOUS"
    end
  end

  def choose_opponent
    answer = nil
    loop do
      prompt message['opponents']
      prompt "Choose your opponent:"
      answer = gets.chomp.downcase
      break if ['a', 'b', 'c', 'd'].include?(answer)
      system("clear")
      prompt "Try again, young padawan. (a, b, c, or d)"
    end
    opponent_choices(answer)
  end

  def choose
    self.move = ROBOT_MOVES[name].sample
    track_move
  end

  private

  def want_to_choose?
    answer = nil
    prompt "Would you like to choose your opponent? (y/n)"
    loop do
      answer = gets.chomp.downcase
      system("clear")
      break if ['y', 'n'].include?(answer)
      system("clear")
      prompt "Choose again, young padawan. (y or n)"
    end
    answer == 'y'
  end
end

class RPSGame
  include Displayable
  include Board

  attr_accessor :human, :computer

  def initialize
    system("clear")
    display_welcome_message
    system("clear")
    prompt message["title"]
    enter_to_play
    @human = Human.new
    @computer = Computer.new
  end

  def enter_to_play
    prompt "Press ENTER to play."
    gets.chomp.downcase
    system("clear")
  end

  def play
    loop do
      game_play
      display_overall_winner
      display_move_history if view_move_history?
      break if !play_again?
    end

    display_goodbye_message
  end

  private

  def keep_score
    if human.move > computer.move
      human.score += 1
    elsif human.move < computer.move
      computer.score += 1
    else
      human.score += 1
      computer.score += 1
    end
  end

  def reset_score!
    human.score = 0
    computer.score = 0
  end

  def view_move_history?
    answer = nil
    prompt "Would you like to view attack history? (y/n)"
    loop do
      answer = gets.chomp
      break if ['y', 'n'].include?(answer.downcase)
      system("clear")
      prompt "Request not found. Please answer with y or n."
    end
    system("clear")
    true if answer.downcase == 'y'
  end

  def play_again?
    answer = nil
    prompt "Would you like to rechallenge #{computer.name}? (y/n)"
    loop do
      answer = gets.chomp
      break if ['y', 'n'].include?(answer.downcase)
      prompt "Choose y or n."
    end
    system("clear")
    reset_score!
    answer.downcase == 'y'
  end

  def game_play
    loop do
      human.choose
      computer.choose
      display_moves
      display_winner
      keep_score
      display_score
      break if human.score == GAMES_TO_WIN || computer.score == GAMES_TO_WIN
    end
  end
end

RPSGame.new.play
