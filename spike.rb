require 'trello'

def calculate_cycle_time_for(card)
  started_on = nil
  finished_on = nil
  card.actions.target.each do |action|
    if action.data.include? 'list'
      if action.data['list']['name'].start_with? 'Doing'
        if started_on.nil? or started_on > action.date
          started_on = action.date
        end
      end
    end
    if action.data.include? 'listAfter'
      if action.data['listAfter']['name'].start_with? 'Doing'
        if started_on.nil? or started_on > action.date
          started_on = action.date
        end
      end
      if action.data['listAfter']['name'].start_with? 'Done'
        if finished_on.nil? or finished_on < action.date
          finished_on = action.date
        end
      end
    end
  end

  if started_on.nil?
    started_on = card.created_at
  end

  finished_on - started_on
end

Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_DEVELOPER_PUBLIC_KEY']
  config.member_token = ENV['TRELLO_MEMBER_TOKEN']
end

boards = Trello::Board.all
boards.each do |board|
  next unless board.name.start_with? 'Conecta - Tareas'

  puts "#{board.id} - #{board.name}"

  cycle_times = []
  board.lists.target.each do |list|
    puts "\t#{list.id} - #{list.name}"
    if list.name == "Done"
      list.cards.target.each do |card|
        cycle_time =  calculate_cycle_time_for(card)
        puts "\t\t #{card.id} - #{card.name} - #{cycle_time}"
        cycle_times << cycle_time
      end
    end
  end
  puts "Average cycle time (days): ", (cycle_times.inject(0.0) { |sum, el| sum + el } / cycle_times.length) / (3600 * 24)
end
