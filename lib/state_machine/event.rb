class Event
  attr_reader :event_name, :rules

  def initialize(event_name)
    @event_name = event_name
    @rules = []
  end

  def change_to(state, rule_options={})
    rule = Rule.new({new_state: state}.merge(rule_options))
    rules.push(rule)
  end
end
