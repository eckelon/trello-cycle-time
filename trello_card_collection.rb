require 'trello'
require_relative 'card'

Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_DEVELOPER_PUBLIC_KEY']
  config.member_token = ENV['TRELLO_MEMBER_TOKEN']
end


class TrelloCardCollection
  def finished_cards_for(board_name)
    boards = Trello::Board.all
    board = boards.select{ |board| board.name == board_name }[0]
    return [] if board.nil?

    closed_lists = board.lists.target.select{ |list| list.name.start_with?('Done') }
    return [] if closed_lists.nil?

    result = []
    closed_lists.each do |closed_list|
      cards = closed_list.cards.target.map do |card|
        actions = card.actions(filter: 'updateCard:idList,createCard').target
        Card.new(
          id: card.id,
          short_id: card.short_id,
          name: card.name,
          url: card.url,
          started_on: calculate_started_on_from(card, actions),
          finished_on: calculate_finished_on_from(actions)
        )
      end
      result.concat(cards)
    end
    result
  end

  private

  def calculate_started_on_from(card, actions)
    started_on = nil
    actions.each do |action|
      if action_for_card_being_moved_to?('Doing', action)
        if started_on.nil? or started_on > action.date
          started_on = action.date
        end
      end
    end

    actions.each do |action|
      if action_for_card_created_on?('Doing', action)
        if started_on.nil? or started_on > action.date
          started_on = action.date
        end
      end
    end
    return card.created_at if started_on.nil?
    started_on
  end

  def action_for_card_being_moved_to?(list_name, action)
    action.data.include? 'listAfter' and not action.data['listAfter']['name'].nil? and action.data['listAfter']['name'].start_with? list_name
  end

  def action_for_card_created_on?(list_name, action)
    action.data.include? 'list' and not action.data['list']['name'].nil? and action.data['list']['name'].start_with? list_name
  end

  def calculate_finished_on_from(actions)
    finished_on = nil
    actions.each do |action|
      if action_for_card_being_moved_to?('Done', action)
        if finished_on.nil? or finished_on < action.date
          finished_on = action.date
        end
      end
    end

    actions.each do |action|
      if action_for_card_created_on?('Done', action)
        if finished_on.nil? or finished_on < action.date
          finished_on = action.date
        end
      end
    end
    finished_on
  end
end
