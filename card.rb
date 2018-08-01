class Card
  attr_reader :id, :short_id, :name, :url, :started_on, :finished_on, :members

  def initialize(args)
    @id = args[:id]
    @short_id = args[:short_id]
    @name = args[:name]
    @url = args[:url]
    @started_on = args[:started_on]
    @finished_on = args[:finished_on]
    @members = args[:members]
  end

  def cycle_time
    finished_on - started_on
  end

  def finished_on_week
    finished_on.strftime("%W - %Y")
  end

  def usernames
    members
  end
end
