import Lean
open Lean Widget

@[widget_module]
def Hello : Widget.Module where
  javascript := include_str ".." / ".." / ".lake" / "build" / "js" / "index.js" -- specify the path to the JavaScript file

#widget Hello
