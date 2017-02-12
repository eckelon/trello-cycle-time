require_relative 'trello_card_collection'
require 'erb'

card_collection = TrelloCardCollection.new
board_name = 'Conecta - Tareas'
now = Time.now
cards = card_collection.finished_cards_for(board_name)

average_cycle_time = cards.inject(0.0) { |sum, el| sum + el.cycle_time } / cards.length

erb = ERB.new(File.read('report.erb'))
result = erb.result(binding)

File.write("#{board_name.gsub(' ', '').downcase}_#{now.strftime("%Y%m%d%H%M")}.html", result)
