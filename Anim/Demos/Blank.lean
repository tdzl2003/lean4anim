import Lean
open Lean Widget Elab Command

structure TwoStageStructure where
  stage1: String
  stage2: String -> String


@[widget_module]
def TwoStageComponent : Widget.Module where
  javascript := include_str ".." / ".." / ".lake" / "build" / "js" / "index.js"

syntax (name := tsWidgetCmd) "#ts_widget " term : command

@[command_elab tsWidgetCmd]
def elabHtmlCmd : CommandElab := fun
  | stx@`(#ts_widget $s:term) => liftCoreM do
    let id := s.raw.getId
    -- 将术语s转换为表达式


    savePanelWidgetInfo
      TwoStageComponent.javascriptHash
      (return json%{id: $(id)})
      stx
  | stx => throwError "Unexpected syntax {stx}."


def MyTwoStageStructure : TwoStageStructure := {
  stage1 := "Hello",
  stage2 := fun s => s ++ " World"
}

 #ts_widget MyTwoStageStructure

 #eval 1
