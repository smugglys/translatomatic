require "thor"

class Translatomatic::CLI < Thor

  desc "translate file", "translate text files"
  option :translator
  option :source_language
  def translate(file = nil)
    Translation.new(options).translate(file)
  end

  desc "hello NAME", "say hello to NAME"
  def hello(name = nil)
    puts "Hello #{name}"
  end

end
