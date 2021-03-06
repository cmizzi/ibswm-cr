module Ibswm
  @[Experimental]
  class ExtendedWindowManagerHints
    NET_SUPPORTED = "_NET_SUPPORTED"
    NET_CLIENT_LIST = "_NET_CLIENT_LIST"
    NET_CLIENT_LIST_STACKING = "_NET_CLIENT_LIST_STACKING"
    NET_CLOSE_WINDOW = "_NET_CLOSE_WINDOW"
    NET_NUMBER_OF_DESKTOPS = "_NET_NUMBER_OF_DESKTOPS"
    NET_CURRENT_DESKTOP = "_NET_CURRENT_DESKTOP"
    NET_DESKTOP_NAMES = "_NET_DESKTOP_NAMES"
    NET_WM_DESKTOP = "_NET_WM_DESKTOP"
    NET_DESKTOP_VIEWPORT = "_NET_DESKTOP_VIEWPORT"
    NET_ACTIVE_WINDOW = "_NET_ACTIVE_WINDOW"
    NET_WM_NAME = "_NET_WM_NAME"
    NET_SUPPORTING_WM_CHECK = "_NET_SUPPORTING_WM_CHECK"
    NET_WM_WINDOW_TYPE = "_NET_WM_WINDOW_TYPE"
    NET_WM_STATE = "_NET_WM_STATE"
    NET_WM_WINDOW_OPACITY = "_NET_WM_WINDOW_OPACITY"
    NET_MOVERESIZE_WINDOW = "_NET_MOVERESIZE_WINDOW"
    NET_WM_MOVERESIZE = "_NET_WM_MOVERESIZE"
    NET_FRAME_EXTENTS = "_NET_FRAME_EXTENTS"
    NET_WM_STATE_FULLSCREEN = "_NET_WM_STATE_FULLSCREEN"
    NET_WM_STATE_HIDDEN = "_NET_WM_STATE_HIDDEN"
    NET_WM_STATE_DEMANDS_ATTENTION = "_NET_WM_STATE_DEMANDS_ATTENTION"
    NET_WM_WINDOW_TYPE_DESKTOP = "_NET_WM_WINDOW_TYPE_DESKTOP"
    NET_WM_WINDOW_TYPE_DOCK = "_NET_WM_WINDOW_TYPE_DOCK"
    NET_WM_WINDOW_TYPE_TOOLBAR = "_NET_WM_WINDOW_TYPE_TOOLBAR"
    NET_WM_WINDOW_TYPE_MENU = "_NET_WM_WINDOW_TYPE_MENU"
    NET_WM_WINDOW_TYPE_UTILITY = "_NET_WM_WINDOW_TYPE_UTILITY"
    NET_WM_WINDOW_TYPE_SPLASH = "_NET_WM_WINDOW_TYPE_SPLASH"
    NET_WM_WINDOW_TYPE_DIALOG = "_NET_WM_WINDOW_TYPE_DIALOG"
    NET_WM_WINDOW_TYPE_DROPDOWN_MENU = "_NET_WM_WINDOW_TYPE_DROPDOWN_MENU"
    NET_WM_WINDOW_TYPE_POPUP_MENU = "_NET_WM_WINDOW_TYPE_POPUP_MENU"
    NET_WM_WINDOW_TYPE_TOOLTIP = "_NET_WM_WINDOW_TYPE_TOOLTIP"
    NET_WM_WINDOW_TYPE_NOTIFICATION = "_NET_WM_WINDOW_TYPE_NOTIFICATION"
    NET_WM_WINDOW_TYPE_COMBO = "_NET_WM_WINDOW_TYPE_COMBO"
    NET_WM_WINDOW_TYPE_DND = "_NET_WM_WINDOW_TYPE_DND"
    NET_WM_WINDOW_TYPE_NORMAL = "_NET_WM_WINDOW_TYPE_NORMAL"

    # Setting up default EWMH implementations. Tells X11 we are supporting additionals attributes.
    def initialize(@x : Display)
      Log.info { "Enabling EWMH support." }

      # List all available `NET_` constants defined and get the intern atom.
      atoms = {{ @type.constants.select { |x| x.starts_with? "NET_" } }}.map { |x| @x.intern_atom(x, false).to_i32 }
      @x.change_property @x.default_root_window, @x.intern_atom(NET_SUPPORTED, false), X11::Atom::Atom, X11::PropModeReplace, Slice.new(atoms.to_unsafe, atoms.size)
    end
  end
end
