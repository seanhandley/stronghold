module ConjugationHelper

  def past_perfective(word)
    word.verb.conjugate tense: :past, person: :third, aspect: :perfective
  end

end