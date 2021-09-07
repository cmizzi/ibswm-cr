require "x11"

module X11::C
  @[Link("x11")]
  lib X
    fun default_error_handler = _XDefaultError(dpy : PDisplay, error : PErrorEvent) : Int32
    fun print_default_error = _XPrintDefaultError(dpy : PDisplay, error : PErrorEvent, fp : Int32*) : Int32
  end
end
