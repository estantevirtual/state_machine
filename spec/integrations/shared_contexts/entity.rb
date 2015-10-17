class Entity
  include StateMachine

  state_machine do |state|
    state.field = :status
    state.initial = :created

    state.on :event_without_param do |event|
      event.change_to :second_state, from: :created
      event.change_to :third_state, from: :second_state
      event.change_to :fourth_state, from: :third_state, if: :is_this_true?
    end

    state.on :event_with_param do |event|
      event.change_to :second_state, from: :created
      event.change_to :third_state, from: :second_state
      event.change_to :fourth_state, from: :third_state, if: :is_param_correct?
    end
  end

  def event_without_param
    super
  end

  def event_with_param(param)
    super
  end

  def is_this_true?
  end

  def is_param_correct?(param)
  end
end
