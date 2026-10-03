
{}
  :about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --contract` before mutations; use `--full` for first orientation or changed contract digest. Manual edits must follow format and schema conventions, then run `calcit edit format`."
  :package |app
  :entries $ {} $ :default
    {} (:description |) (:init-fn 'app.main/main!) (:mode :js) (:reload-fn 'app.main/reload!) (:target :browser)
      :feature-policy $ {}
      :modules $ [] |js-ffi/ |quamolit/
      :type-slots $ {}
  :files $ {} $ 'app.main
    %{} 'FileEntry
      :defs $ {}
        'Chain $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Chain (:seed 'Number)
            :segments $ :: 'List 'app.main/Segment
          :examples $ []
          :schema $ :: 'StructDef
        'Segment $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Segment (:ring 'Number) (:from 'Number) (:to 'Number) (:color 'quamolit.motion/ColorRgba)
          :examples $ []
          :schema $ :: 'StructDef
        'Vortex $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Vortex (:seed 'Number) (:generation 'Number)
            :segments $ :: 'List 'app.main/Segment
          :examples $ []
          :schema $ :: 'StructDef
        'draw! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn draw! (context document width height dpr)
            renderer/draw-document! context (project-pixels document dpr) width height no-image
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'js-ffi.canvas-batches/CanvasContextHost 'quamolit.scene-ir/SceneDocument 'Number 'Number 'Number
            :features $ #{} :js-ffi
        'gen-chain $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn gen-chain (chain base ring)
            let
                random-step $ next-seed $ :seed chain
                second $ next-seed random-step
                step $ * (/ random-step 2147483647) (/ 3 ring)
              if
                or
                  > (+ base step) 1
                  and (> base 0.7)
                    > (/ second 2147483647) 0.4
                struct-with chain $ :seed second
                let
                    third $ next-seed second
                    fourth $ next-seed third
                    fifth $ next-seed fourth
                    segment $ Segment :ring ring :from base :to (+ base step) :color $ segment-color
                      * 360 $ / third 2147483647
                      / fourth 2147483647
                      / fifth 2147483647
                  recur
                    struct-with chain (:seed fifth)
                      :segments $ conj (:segments chain) segment
                    + base step $ / 0.2 ring
                    , ring
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'app.main/Chain)
            :args $ [] 'app.main/Chain 'Number 'Number
        'generate $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn generate (seed generation end-ring)
            assert |invalid-vortex-seed $ and (motion/finite-number? seed) (> seed 0) (< seed 2147483647)
              = seed $ floor seed
            let
                chain $ foldl (range 2 end-ring)
                  Chain :seed seed :segments $ []
                  fn (current ring) (gen-chain current 0 ring)
              Vortex :seed seed :generation generation :segments $ :segments chain
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'app.main/Vortex)
            :args $ [] 'Number 'Number 'Number
        'hsl-channel $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn hsl-channel (h s l offset)
            let
                k $ remainder
                  + (/ h 30) offset
                  , 12
                a $ * s $ if (< l 0.5) l (- 1 l)
                low $ if
                  < (- k 3) (- 9 k)
                  - k 3
                  - 9 k
                high $ if (> low -1) low -1
                factor $ if (< high 1) high 1
              - l $ * a factor
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Number)
            :args $ [] 'Number 'Number 'Number 'Number
        'initial $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn initial (seed) (generate seed 0 40)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'app.main/Vortex)
            :args $ [] 'Number
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! ()
            assert |vortex-entry-empty $ >
              count $ :nodes $ sample (initial 17) 0 1100 1000
              , 0
            , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
        'next-seed $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn next-seed (seed)
            remainder (* 48271 seed) 2147483647
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Number)
            :args $ [] 'Number
        'no-image $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn no-image (id version) (raise |vortex-has-no-images)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'js-ffi.browser/ImageHost)
            :args $ [] 'String 'Number
        'project-pixels $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn project-pixels (document dpr)
            let
                root $ scene/SceneNode :id |vortex-root :key |vortex-root :parent | :bindings ([]) :interaction (scene/SceneInteraction :none) :content $ scene/SceneContent :group
                  scene/GroupNode :transform
                    scene/Matrix2D :a dpr :b 0 :c 0 :d dpr :e 0 :f 0
                    , :clip (scene/ClipSpec :none) :opacity 1
                children $ map (:nodes document)
                  fn (node)
                    struct-with node $ :parent |vortex-root
              scene/SceneDocument :nodes $ concat ([] root) children
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'quamolit.scene-ir/SceneDocument)
            :args $ [] 'quamolit.scene-ir/SceneDocument 'Number
        'regenerate $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn regenerate (model)
            generate
              next-seed $ :seed model
              inc $ :generation model
              , 36
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'app.main/Vortex)
            :args $ [] 'app.main/Vortex
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn reload! () &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
        'remainder $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn remainder (value divisor)
            - value $ * divisor $ floor (/ value divisor)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Number)
            :args $ [] 'Number 'Number
        'sample $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn sample (model seconds width height)
            assert |invalid-vortex-time $ and (motion/finite-number? seconds) (>= seconds 0)
            assert |invalid-vortex-viewport $ and (motion/finite-number? width) (motion/finite-number? height) (> width 0) (> height 0)
            scene/SceneDocument :nodes $ map-indexed (:segments model)
              fn (index segment) (segment-node segment index seconds width height)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'quamolit.scene-ir/SceneDocument)
            :args $ [] 'app.main/Vortex 'Number 'Number 'Number
        'segment-color $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn segment-color (h s l)
            motion/ColorRgba :r (hsl-channel h s l 0) :g (hsl-channel h s l 8) :b (hsl-channel h s l 4) :a 1
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'quamolit.motion/ColorRgba)
            :args $ [] 'Number 'Number 'Number
        'segment-node $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn segment-node (segment index seconds width height)
            let
                radius $ * 12 $ :ring segment
                rotation $ / (* seconds 400) (:ring segment)
                start $ * (/ &PI 180)
                  +
                    * 360 $ :from segment
                    , rotation
                span $ * (* 2 &PI)
                  - (:to segment) (:from segment)
                steps $ if (> span 0)
                  ceil $ / span 0.04
                  , 1
                points $ map
                  range 0 $ inc steps
                  fn (step)
                    let
                        angle $ + start $ * span (/ step steps)
                      motion/Vec2 :x
                        + (/ width 2)
                          * radius $ cos angle
                        , :y $ + (/ height 2)
                          * radius $ sin angle
              scene/SceneNode :id (str |arc- index) :key (str |arc- index) :parent | :bindings ([]) :interaction (scene/SceneInteraction :none) :content $ scene/SceneContent :polyline $ scene/PolylineNode :points points :width 4 :stroke (:color segment)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'quamolit.scene-ir/SceneNode)
            :args $ [] 'app.main/Segment 'Number 'Number 'Number 'Number
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.main
          :require (quamolit.motion :as motion) (quamolit.scene-ir :as scene) (quamolit.canvas-scene :as renderer)
