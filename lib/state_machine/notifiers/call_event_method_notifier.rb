class CallEventMethodNotifier
  attr_reader :method_to_call, :message_args, :change_state_value_notifier, :state_template,
    :entity_with_state

  def initialize(params)
    @entity_with_state = params[:entity]
    @state_template = params[:state_template]
    @method_to_call = params[:method_to_call]
    @message_args = params[:message_args]
    @change_state_value_notifier = params[:change_state_value_notifier]
  end

  def notify!
    event = state_template.find_event(method_to_call)

    success = false
    event.rules.each do |rule|
      if rule.must_have_specific_state?
        if is_in_state?(rule.state_should_be)
          if rule.has_conditional?
            if execute_conditional_method(rule.conditional_method, message_args) == true
              change_current_state_value_to(rule.change_to)
              success = true
            end
          else
            change_current_state_value_to(rule.change_to)
            success = true
          end
        end
      else
        change_current_state_value_to(rule.change_to)
        success = true
      end
      break if success == true
    end

    raise StateTransactionNotPermittedError if success == false
  end

  private

  def is_in_state?(state)
    state_template.state == state
  end

  def execute_conditional_method(method, args_to_send)
    entity_with_state.send(method, *args_to_send)
  end

  def change_current_state_value_to(value)
    ChangeStateValueNotifier.new({
      state_template: state_template,
      new_value: value
    }).notify!
  end
end
