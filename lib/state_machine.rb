module StateMachine
  def self.included(base)
    base.extend(ClassMethods)
  end

  def method_missing(called_method, *args)
    if is_calling_state_attribute?(called_method)
      current_state_value!
    elsif is_changing_state_attribute?(called_method)
      change_current_state_value(args.first)
    elsif is_calling_an_event?(called_method)
      execute_event({event_called: called_method, args: args})
    else
      super
    end
  end

  private

  def is_calling_state_attribute?(method)
    method == ClassMethods.state_template.state_field_name
  end

  def is_changing_state_attribute?(method)
    state_field_name = ClassMethods.state_template.state_field_name
    method.to_s == "#{state_field_name}="
  end

  def current_state_value!
    ClassMethods.state_template.state
  end

  def change_current_state_value(new_state)
    ClassMethods.state_template.state = new_state
  end

  def is_calling_an_event?(called_method)
    !ClassMethods.state_template.find_event(called_method).nil?
  end

  def change_current_state_value_to(new_state)
    ClassMethods.state_template.state = new_state
  end

  def is_in_state?(state)
    ClassMethods.state_template.state == state
  end

  def execute_event(params)
    event_name = params[:event_called]
    args_sent_to_event = params[:args]

    event = ClassMethods.state_template.find_event(event_name)

    success = false
    event.rules.each do |rule|
      if rule.must_have_specific_state?
        if is_in_state?(rule.state_should_be)
          if rule.has_conditional?
            if execute_conditional_method(rule.conditional_method, args_sent_to_event) == true
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

  def execute_conditional_method(method, args_to_send)
    self.send(method, *args_to_send)
  end

  module ClassMethods
    def state_machine
      @@state_template = StateTemplate.new
      yield @@state_template
    end

    def self.state_template
      @@state_template
    end
  end
end
