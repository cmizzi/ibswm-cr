require "commander"
require "colorize"
require "socket"

DEFINITION = ARGV.clone

# This is the main function used in the program : send the exact same command to the daemon.
def send_command_to_socket(cmd : Commander::Command, options : Commander::Options, arguments : Array(String))
  UNIXSocket.open options.string["socket"], Socket::Type::STREAM, do |sock|
    sock.puts DEFINITION

    response = sock.gets
    raise response.to_s if response != "ok"
  rescue e
    puts "Error received from the daemon : \"#{e.message}\".".colorize(:red)
  end
rescue e
  puts "Error while communicating with the socket : \"#{e.message}\".".colorize(:red)

  if options.bool["verbose"]
    puts "| #{e.backtrace.join "\n| "}"
  end
end

# Define the main command structure. This contains every subcommands, flags, etc.
cli = Commander::Command.new do |cmd|
  cmd.use  = "ibsc"
  cmd.long = "CLI utiliy to send command to the main Ibspwm daemon."

  cmd.flags.add do |flag|
    flag.name        = "socket"
    flag.short       = "-s"
    flag.long        = "--socket"
    flag.default     = "/var/run/ibswm.sock"
    flag.description = "Socket to send command to."
    flag.persistent  = true
  end

  cmd.flags.add do |flag|
    flag.name        = "verbose"
    flag.short       = "-v"
    flag.long        = "--verbose"
    flag.default     = false
    flag.description = "Verbose mode"
    flag.persistent  = true
  end

  cmd.run do |options, arguments|
    puts cmd.help
  end

  cmd.commands.add do |cmd|
    cmd.use   = "config"
    cmd.short = "Configure a command."
    cmd.long  = cmd.short

    cmd.flags.add do |flag|
      flag.name        = "monitor"
      flag.short       = "-m"
      flag.long        = "--monitor"
      flag.default     = ""
      flag.description = "Specific monitor to apply config to."
      flag.persistent  = true
    end

    cmd.commands.add do |cmd|
      cmd.use   = "monitor"
      cmd.short = "Configure the monitor."
      cmd.long  = cmd.short

      cmd.flags.add do |flag|
        flag.name        = "alias"
        flag.short       = "-a"
        flag.long        = "--alias"
        flag.default     = ""
        flag.description = "Alias a name to the monitor."
      end

      cmd.run do |options, arguments|
        send_command_to_socket cmd, options, arguments
      end
    end

    cmd.run do |options, arguments|
      puts cmd.help
    end
  end
end

Commander.run(cli, ARGV)
