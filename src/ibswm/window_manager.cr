require "../x11/*"
require "commander"

module Ibswm
  include X11

  class WindowManager
    # Define the main X11 connection.
    #
    # Un-initialize until the constructor is done.
    @x : Display

    # Define the list of options set from the CLI.
    @options : Commander::Options

    # Initialize the window manager.
    #
    # Initialize the X11 connection and prepare EWMH protocol.
    def initialize(@options : Commander::Options)
      # First, initialize the error handler.
      X.set_error_handler ->(display : X11::C::X::PDisplay, error : X11::C::X::PErrorEvent) {
        # Let's the scheduler advance on another task just before existing.
        Fiber.yield

        # Call the original error handler if the verbose mode is set.
        X.default_error_handler display, error
      }

      # DEBUG Remove the :1 because it's only useful on development mode.
      @x = Display.new ":1"
      @ewmh = ExtendedWindowManagerHints.new @x

      take_ownership
    end

    # Try to take the X11 ownership.
    #
    # If another window manager is running, we won't be able to change the root window attribute using
    # `SubstructureRedirectMask`, X11 will raise an error. If we can't take the ownership, we won't be able to start
    # our window manager.
    #
    # See `initialize` to get more information.
    def take_ownership
      Log.info { "Obtaining X11 ownership." }

      attrs = SetWindowAttributes.new
      attrs.event_mask = SubstructureRedirectMask | SubstructureNotifyMask

      @x.change_window_attributes @x.default_screen.root_window, CWEventMask.to_u64, attrs
    end

    def loop
      Log.info { "Listening for incoming events." }

      loop do
        pending_events = @x.pending

        # There's no event to process. Just sleep a bit and try again.
        if pending_events == 0
          sleep 1.seconds
          next
        end

        # In order to process all the event at the same time, go to the next event until the pending variation.
        pending_events.times do
          e = @x.next_event

          case e
          when MapRequestEvent
            attrs = SetWindowAttributes.new
            attrs.event_mask = FocusChangeMask

            @x.change_window_attributes e.window, CWEventMask.to_u64, attrs
            @x.reparent_window e.window, @x.default_root_window, 0, 0
            @x.map_window e.window

            Log.info { "Map window #{e.window}." }
          when ConfigureRequestEvent
            attrs = WindowChanges.new
            attrs.width = e.width
            attrs.height = e.height
            attrs.x = e.x
            attrs.y = e.y

            @x.configure_window e.window, CWX | CWY | CWWidth | CWHeight, attrs

            Log.info { "Configure window #{e.window}." }
          when UnmapEvent
            Log.info { "Unmap window #{e.window}." }
          end
        end

        Fiber.yield
      end

      Log.info { "See you later!" }
      0
    ensure
      close
    end

    def close
      @x.close unless @x.nil?
    end
  end
end
