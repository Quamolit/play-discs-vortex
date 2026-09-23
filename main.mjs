// Temporary compile-only entry. The original application remains in app.main/main!.
import { main_$x_ } from "./js-out/app.bootstrap.mjs"

main_$x_()

if (import.meta.hot) {
  import.meta.hot.accept('./js-out/app.bootstrap.mjs', (main) => {
    main.reload_$x_()
  })
}
