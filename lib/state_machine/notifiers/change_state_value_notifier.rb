class ChangeStateValueNotifier
  attr_reader :state_template, :new_value

  def initialize(params)
    @state_template = params[:state_template]
    @new_value = params[:new_value]
  end

  def notify!
    state_template.state = new_value
  end
end
