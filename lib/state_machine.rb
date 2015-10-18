module StateMachine
  def self.included(base)
    base.extend(ClassMethods)
  end

  def method_missing(called_method, *args)
    factory_params = {
      object_called: self,
      state_template: ClassMethods.state_template,
      message_name: called_method,
      message_args: args
    }

    factory = StateNotifierFactory.new factory_params

    if factory.is_notifying_state_machine?
      factory.notifier.notify!
    else
      super
    end
  end

  private

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
