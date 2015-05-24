require 'logger'

class Logging
  LOG_DIR = 'log/'

  def initialize
    FileUtils.mkpath LOG_DIR
    @logger = Logger.new File.new("#{LOG_DIR}/development.log", 'a+')
  end
end
