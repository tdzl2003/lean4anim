import Anim.Demos.Stage1
import Anim.Demos.Stage2

def MyTwoStageStructure: TwoStageStructure := {
  stage1 := "Hello",
  stage2 := fun s => s ++ " World"
}

#eval 1

#ts_widget MyTwoStageStructure
