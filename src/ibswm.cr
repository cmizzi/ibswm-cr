require "log"
require "socket"
require "commander"
require "colorize"
require "./ibswm/*"

at_exit { GC.collect }
Log.setup_from_env(default_level: :debug)

module Ibswm
  VERSION = "0.1.0"

  def self.handle_client(wm, client)
    pp client.gets
    pp wm

    client.puts "ok"
  end

  cli = Commander::Command.new do |cmd|
    cmd.use  = "ibswm"
    cmd.long = "Run the daemon."

    cmd.flags.add do |flag|
      flag.name        = "socket"
      flag.short       = "-s"
      flag.long        = "--socket"
      flag.default     = "/tmp/ibswm.sock"
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

    # Execute the main function. This function will simply call the `WindowManager` loop and
    # the `UNIXServer` socket server to handle user commands.
    cmd.run do |options, arguments|
      wm = WindowManager.new options
      server = UNIXServer.new options.string["socket"]

      # Handle SIGINT signal. This is super-useful for the `UNIXServer` because it's the only
      # way to close the socket properly (and remove the file).
      Signal::INT.trap do
        Log.info { "Received SIGINT signal." }

        # If there's anything else to do before existing, do it right now (like cleanup, etc.).
        Fiber.yield

        # Exit the program.
        exit
      end

      at_exit {
        Log.info { "Closing socket and X11 connection now." }

        server.close
        wm.close
      }

      # Handle socket communicate for the user commands.
      spawn do
        while client = server.accept?
          spawn handle_client(wm, client)
        end

        server.close
      end

      # Handle the X11 events loop.
      wm.loop
    end
  end

  # Run the executable.
  Commander.run(cli, ARGV)
end
