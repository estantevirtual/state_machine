class Rule
  attr_reader :rule_options

  def initialize(params={})
    @rule_options = params
  end

  def has_conditional?
    !@rule_options[:if].nil?
  end

  def must_have_specific_state?
    !@rule_options[:from].nil?
  end

  def conditional_method
    @rule_options[:if]
  end

  def change_to
    @rule_options[:new_state]
  end

  def state_should_be
    @rule_options[:from]
  end
end
