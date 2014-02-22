require 'rubygems'
require 'bunny'
require 'cinch'
require 'yaml'

class IrcConfig
  attr_reader :nick, :login, :password, :host, :port, :channels

  def initialize(configuration_map)
    @nick = configuration_map['irc_nick']
    @login = configuration_map['irc_login']
    @password = configuration_map['irc_password']
    @host = configuration_map['irc_host']
    @port = configuration_map['irc_port']
    @channels = configuration_map['channels']
  end  
end  

class RabbitConfig
  attr_reader :login, :password, :host, :port, :queue

  def initialize(configuration_map)
    @login = configuration_map['rabbit_login']
    @password = configuration_map['rabbit_password']
    @host = configuration_map['rabbit_host']
    @port = configuration_map['rabbit_port']
    @queue = configuration_map['rabbit_queue']
  end
  
  def to_s
    return "amqp://#{@login}:#{@password}@#{@host}:#{@port}"
  end
end

configuration_map = YAML.load_file('configuration.yml')
$irc_config = IrcConfig.new(configuration_map)
$rabbit_config = RabbitConfig.new(configuration_map)

bot = Cinch::Bot.new do    
  configure do |c|
    c.nick = $irc_config.nick
    c.user = $irc_config.login
    c.password = $irc_config.password
    c.server = $irc_config.host
    c.port = $irc_config.port
    c.channels = $irc_config.channels
  end

  helpers do
    def post_message(m)
      # Start a communication session with RabbitMQ
      conn = Bunny.new($rabbit_config.to_s)
      conn.start

      # open a channel
      ch = conn.create_channel

      # declare a queue
      q  = ch.queue($rabbit_config.queue, :durable => true, :auto_delete => false, 
        :arguments => { "x-message-ttl" => 60000, "x-max-length" => 500 })
      
      command = m.message[1..-1].downcase
      nickname = m.user.nick.downcase.capitalize
      # publish a message to the default exchange which then gets routed to this queue
      q.publish("#{nickname},#{command},#{Time.now}", {:content_type => 'text/plain'})

      # close the connection
      conn.stop 
    end
  end

  on :message, /^!(.+)/ do |m|    
    post_message(m)    
  end
end

bot.start
