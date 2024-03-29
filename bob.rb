# This is bob
# Bob can answer to silence, a question, yelling, and neutral sentence
class Bob
  RESPONSES = [:silence, :question, :yelling, :neutral]

  def hey(statement)
    @statement = statement and bobs_response
  end

  private

    def response_types
      @response_types ||= Statement.new(@statement).types
    end

    def count
      response_types.count
    end

    def bobs_response
      if count == 1
        Response.to response_types.first
      elsif count == 2 && types_include?( :question, :yelling )
        Response.to :yelling
      end
    end

    def types_include?(*args)
      args.reduce(true) { |bool, arg| bool = bool && RESPONSES.include?(arg) }
    end
end

# Abstracting responses in case more complex responses emerge in the future.
class Response
  RESPONSES = { silence:  'Fine. Be that way!', question: 'Sure.',
                yelling:  'Woah, chill out!',   neutral:  'Whatever.' }

  def self.to(statement)
    RESPONSES[statement]
  end
end

class Statement
  def initialize(statement)
    @statement = statement.gsub '?', ' ?'
    # Add space before a '?' so words wont stick to the '?'.
    # We need 'hello ?' not 'hello?'
  end

  # List the types for the statement
  def types
    types = []
    push_if = ->(method, type) { types.push(type) if send(method); types}
    push_if[:question?, :question]
    push_if[:yelling?,  :yelling]
    push_if[:silence?,  :silence]
    push_if[:neutral?,  :neutral]
  end

  def question?
    has_interogation_mark?
  end

  def yelling?
    all_caps? # For this assignment, yelling is when a statement is in all caps
  end

  def silence?
    # if you have any letter, its not silence
    !(@statement.count('a-zA-Z0-9') > 0)
  end

  def neutral?
    !silence? && !question? && !yelling?
  end

  private

    def has_interogation_mark?
      @statement.end_with? '?'
    end

    def has_exclamation_mark?
      @statement.end_with? '!'
    end

    def all_caps?
      statement = filter_acronyms @statement
      !!((statement == statement.upcase) && statement.match(/[a-zA-Z]/))
    end

    def only_numbers?
      !!@statement.match(/[a-zA-Z]/)
    end

    def filter_acronyms(statement)
      split_special_chars(@statement)
        .reject { |word| is_acronym? word }
        .join ' '
    end

    def split_special_chars(statement)
      # whitespace, dot, comma, apostatementophe
      statement.split /[\s\.\,\'\?]/
    end

    def is_acronym?(statement)
      Acronyms.include? statement
    end

    def strip(statement)
      statement.gsub(/\s+/, '')
    end
end

class Acronyms
  LIST = %w( DMV  NASA NASCAR  FBI CIA )

  def self.include?(statement)
    LIST.include?(statement)
  end
end
