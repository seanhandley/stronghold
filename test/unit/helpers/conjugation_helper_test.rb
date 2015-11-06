require 'test_helper'

class TestModel
  include ConjugationHelper
end

class ConjugationHelperTest < CleanTest
  def setup
    @model = TestModel.new
  end

  def test_past_perfective
    mock_verb = Minitest::Mock.new
    options = {tense: :past, person: :third, aspect: :perfective}
    mock_verb.expect(:conjugate, nil, [options])
    mock = Minitest::Mock.new
    mock.expect(:verb, mock_verb)

    @model.past_perfective(mock)

    mock_verb.verify
    mock.verify
  end

end