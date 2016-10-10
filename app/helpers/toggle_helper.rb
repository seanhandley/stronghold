module ToggleHelper
  def default_toggle_params
    {
      toggle:   "toggle",
      on:       "On",
      off:      "Off",
      size:     "small",
      onstyle:  "info",
      offstyle: "danger",
      style:    "ios"
    }
  end
end