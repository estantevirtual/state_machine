class RetrieveStateValueNotifier
  attr_reader :state_template

  def initialize(params)
    @state_template = params[:state_template]
  end

  def notify!
    state_template.state
  end
end
