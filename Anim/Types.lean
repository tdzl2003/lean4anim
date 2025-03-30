import Lean

open Lean

namespace Anim

structure Point where
  x: Float := 0
  y: Float := 0
deriving Repr, FromJson, ToJson, TypeName

structure Color where
  r: Float := 0
  g: Float := 0
  b: Float := 0
  a: Float := 1
deriving Repr, FromJson, ToJson, TypeName

inductive RenderCall where
  | clear (color: Color)
  | point (center: Point) (radius : Float) (color: Color)
  | line (p1 p2: Point) (color: Color)
deriving Repr, FromJson, ToJson, TypeName

structure SceneMeta where
  width: Nat
  height: Nat
deriving Repr, FromJson, ToJson, TypeName

structure Scene where
  meta: SceneMeta
deriving Repr

structure FinalOutput where
  meta: SceneMeta
  frames: List (List RenderCall)
deriving FromJson, ToJson, TypeName

def Scene.toFinalOutput (s: Scene): FinalOutput := {
  meta := s.meta,
  -- 模拟数据，因为动画生成流程尚未实现
  frames := [
    [
      RenderCall.clear {r := 0.0, g := 0.0, b := 0.0, a := 1.0},
      RenderCall.point {x := 10.0, y := 10.0} 5.0 {r := 1.0, g := 1.0, b := 1.0, a := 1.0},
      RenderCall.line {x := 20.0, y := 20.0} {x := 30.0, y := 30.0} {r := 1.0, g := 1.0, b := 1.0, a := 1.0}
    ]
  ],
}

-- Monad for Anim
structure Request where
  type: String
  args: Option Json
deriving FromJson, ToJson

structure Response where
  resp: Json
deriving FromJson, ToJson

inductive AnimM(α: Type) where
  | pure (a: α)
  | request (r: Request) (f: Response → AnimM α)

abbrev Anim := AnimM Scene

def AnimM.bind {α β: Type} (x: AnimM α) (f: α → AnimM β): AnimM β := match x with
  | AnimM.pure a => f a
  | AnimM.request r k => AnimM.request r (fun resp => AnimM.bind (k resp) f)

instance : Monad AnimM where
  bind := AnimM.bind
  pure := AnimM.pure

-- 发送一个请求到JS端处理，然后继续流程
def request (type: String) (args: Option Json): AnimM Response := do
  let r ← AnimM.request {type := type, args := args} fun resp => pure resp
  return r

end Anim
