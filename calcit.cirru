
{}
  :about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --contract` before mutations; use `--full` for first orientation or changed contract digest. Manual edits must follow format and schema conventions, then run `calcit edit format`."
  :package |app
  :entries $ {} $ :default
    {} (:description |) (:init-fn 'app.bootstrap/main!) (:mode :js) (:reload-fn 'app.bootstrap/reload!) (:target :browser)
      :feature-policy $ {}
      :modules $ [] |pointed-prompt/ |js-ffi/ |quamolit/
      :type-slots $ {}
  :files $ {}
    'app.bootstrap $ %{} 'FileEntry
      :defs $ {}
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! () &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn reload! () &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.bootstrap
    'app.comp.container $ %{} 'FileEntry
      :defs $ {}
        'Segment $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Segment (:r 'Number) (:from 'Number) (:to 'Number) (:color 'String)
          :examples $ []
          :schema $ :: 'StructDef
        'comp-container $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-container (store)
            let
                states $ :states store
                state $ either (:data states)
                  {}
                    :trails $ []
                    :rot 0
                cursor $ []
                speed $ :speed conf
                rot0 $ :rot state
              []
                fn (elapsed d!)
                  if
                    empty? $ :trails state
                    d! cursor $ assoc state :trails $ gen-trails 2 40
                    d! cursor $ update state :rot $ fn (x)
                      + x $ * elapsed 10
                group ({})
                  rect $ {} (:w js/window.innerWidth) (:h js/window.innerHeight) (:x 0) (:y 0) (:fill-style |black)
                  group ({}) & $ -> (:trails state)
                    map $ fn (trail)
                      group ({}) & $ -> trail $ map
                        fn (seg)
                          let
                              rot $ * speed $ / rot0 (:r seg)
                            arc $ {} (:x 0) (:y 0)
                              :s-angle $ +
                                * 360 $ :from seg
                                , rot
                              :e-angle $ +
                                * 360 $ :to seg
                                , rot
                              :line-width 4
                              :r $ * 12 $ :r seg
                              :line-cap :round
                              :stroke-style $ :color seg
                  group ({})
                    button $ {} (:x -200) (:y -100) (:width 80) (:height 40) (:text |Gen)
                      :text-color $ hsl 0 0 100 0.4
                      :surface-color $ hsl 0 0 40 0.5
                      :event $ {} $ :click
                        fn (e d!)
                          d! cursor $ assoc state :trails $ gen-trails 2 36
                    , el-fullscreen
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Dynamic
            :features $ #{} :js-ffi
        'el-fullscreen $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def el-fullscreen
            button $ {} (:x -200) (:y 0) (:width 80) (:height 40) (:text |Full)
              :text-color $ hsl 0 0 100 0.4
              :surface-color $ hsl 0 0 40 0.5
              :event $ {} $ :click
                fn (e d!) (js/document.body.requestFullscreen)
          :examples $ []
          :schema $ :: 'Dynamic
        'gen-chain $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn gen-chain (acc base r)
            let
                step $ rand $ / (:seed conf) r
              if
                or
                  > (+ step base) 1
                  and (> base 0.7)
                    > (rand 1) 0.4
                , acc $ recur
                  conj acc $ %{} Segment (:r r) (:from base)
                    :to $ + base step
                    :color $ hsl (rand 360) (rand 100) (rand 100)
                  + base step $ / (:gap-limit conf) r
                  , r
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Dynamic 'Dynamic 'Dynamic
        'gen-trails $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn gen-trails (from to)
            -> (range from to)
              map $ fn (r)
                gen-chain ([]) 0 r
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Dynamic 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.container
          :require
            quamolit.util.string :refer $ hsl
            quamolit.alias :refer $ defcomp group >> line arc rect
            quamolit.render.element :refer $ translate button
            |@calcit/std :refer $ rand
            app.config :refer $ conf
            quamolit.hud-logs :refer $ hud-log
    'app.config $ %{} 'FileEntry
      :defs $ {} $ 'conf
        %{} 'CodeEntry (:doc |)
          :code $ quote $ def conf
            {} (:gap-limit 0.2) (:seed 3) (:speed 40)
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.config
    'app.main $ %{} 'FileEntry
      :defs $ {}
        '*raq-loop $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defatom *raq-loop nil
          :examples $ []
          :schema $ :: 'Dynamic
        '*render-loop $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defatom *render-loop nil
          :examples $ []
          :schema $ :: 'Dynamic
        '*store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defatom *store
            {} $ :states $ {}
          :examples $ []
          :schema $ :: 'Dynamic
        'dispatch! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn dispatch! (op op-data)
            if (list? op)
              recur :states $ [] op op-data
              do (; println |dispatch op op-data) (; js/console.log @*store)
                let
                    new-tick $ get-tick
                    new-store $ updater @*store op op-data new-tick
                  reset! *store new-store
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Dynamic 'Dynamic
            :features $ #{} :js-ffi
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! () (load-console-formatter!)
            let
                target $ js/document.querySelector |#app
              configure-canvas target
              setup-events target dispatch!
              render-loop! 0
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ []
            :features $ #{} :js-ffi
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn reload! ()
            if (nil? build-errors)
              do (js/clearTimeout @*render-loop) (js/cancelAnimationFrame @*raq-loop) (render-loop! 0) (hud! |ok~ |Ok)
              hud! |error build-errors
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ []
            :features $ #{} :js-ffi
        'render-loop! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-loop! (t)
            let
                target $ js/document.querySelector |#app
              ; js/console.log |store @*store
              render-page (comp-container @*store) target dispatch!
              ; reset! *render-loop $ js/setTimeout
                fn () $ reset! *raq-loop $ js/requestAnimationFrame render-loop!
                , 10
              reset! *raq-loop $ js/requestAnimationFrame render-loop!
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Dynamic
            :features $ #{} :js-ffi
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.main
          :require
            app.comp.container :refer $ comp-container
            quamolit.core :refer $ render-page configure-canvas setup-events
            quamolit.util.time :refer $ get-tick
            app.updater :refer $ updater
            |./calcit.build-errors :default build-errors
            |bottom-tip :default hud!
    'app.schema $ %{} 'FileEntry
      :defs $ {} $ 'task
        %{} 'CodeEntry (:doc |)
          :code $ quote $ def task
            {} (:text |) (:id nil) (:done? false)
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.schema
    'app.updater $ %{} 'FileEntry
      :defs $ {} $ 'updater
        %{} 'CodeEntry (:doc |)
          :code $ quote $ defn updater (store op op-data tick) (; js/console.log "|store update:" op op-data tick)
            case-default op
              do (js/console.log "|unknown op" op) store
              :states $ update-states store op-data
              :gc-states $ gc-states store op-data
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Dynamic 'Dynamic 'Dynamic 'Dynamic
            :features $ #{} :js-ffi
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater
          :require (app.schema :as schema)
            quamolit.cursor :refer $ update-states gc-states
