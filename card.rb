class Card
  attr_reader :id, :short_id, :name, :url, :started_on, :finished_on

  def initialize(args)
    @id = args[:id]
    @short_id = args[:short_id]
    @name = args[:name]
    @url = args[:url]
    @started_on = args[:started_on]
    @finished_on = args[:finished_on]
  end

  def cycle_time
    finished_on - started_on
  end
end
