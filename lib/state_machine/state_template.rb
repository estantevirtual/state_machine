class StateTemplate
  attr_reader :state_field_name, :events_by_name

  def initialize
    @state_value = nil
    @events_by_name = {}
  end

  def state
    @state_value
  end

  def find_event(name)
    events_by_name[name]
  end

  def state=(v)
    @state_value = v
  end

  def field=(field_name)
    @state_field_name = field_name
  end

  def initial=(initial_status)
    @state_value = initial_status
  end

  def on(event_name)
    event = Event.new(event_name)
    events_by_name[event_name] = event
    yield event
  end
end
