class ApplicationDecorator < SimpleDelegator

  def initialize(klass)
    @model = klass
    super(klass)
  end

  def class
    model.class
  end

  private

  def model
    @model
  end

end