class StateNotifierFactory
  attr_reader :object_called, :state_template,
    :message_name, :message_args

  def initialize(params={})
    @object_called = params[:object_called]
    @state_template = params[:state_template]
    @message_name = params[:message_name]
    @message_args = params[:message_args]
  end

  def is_notifying_state_machine?
    is_calling_state_attribute? ||
      is_changing_state_attribute? ||
      is_calling_an_event?
  end

  def notifier
    if is_changing_state_attribute?
      build_change_state_value_notifier!
    elsif is_calling_state_attribute?
      build_retrieve_state_value_notifier!
    elsif is_calling_an_event?
      build_call_event_method_notifier!
    end
  end

  private

  def build_call_event_method_notifier!
    @call_event_method_notifier ||= CallEventMethodNotifier.new({
      entity: object_called,
      state_template: state_template,
      method_to_call: message_name,
      message_args: message_args,
      change_state_value_notifier: build_change_state_value_notifier!
    })
  end

  def build_change_state_value_notifier!
    @change_state_value_notifier ||= ChangeStateValueNotifier.new({
      state_template: state_template,
      new_value: message_args.first
    })
  end

  def build_retrieve_state_value_notifier!
    @retrieve_state_value_notifier ||= RetrieveStateValueNotifier.new({ state_template: state_template })
  end

  def is_calling_state_attribute?
    message_name.to_s == state_template.state_field_name.to_s
  end

  def is_changing_state_attribute?
    message_name.to_s == "#{state_template.state_field_name}="
  end

  def is_calling_an_event?
    !state_template.find_event(message_name).nil?
  end
end
