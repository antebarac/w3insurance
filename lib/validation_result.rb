class ValidationResult
  attr_reader :messages

  def initialize
    @messages = Array.new
  end

  def add (name, message)
    @messages << [ name, message ]
  end

  def include?(name, message)
    @messages.include?([ name, message ])
  end

  def ok?
    @messages.size == 0
  end

  def to_s
    result = ''
    @messages.each do |message|
       result += "[ #{message[0]} - #{message[1]} ]\n"
    end
    result
  end

end
