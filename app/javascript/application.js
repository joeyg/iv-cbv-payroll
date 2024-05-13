// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

import "@uswds/uswds"

// make sure USWDS components are wired to their behavior after a Turbo navigation
import components from "@uswds/uswds/src/js/components"

document.addEventListener("turbo:load", () => {
  this.initialLoad = true;

  if (this.initialLoad) {
    // initial domready is handled by `import "uswds"` code
    this.initialLoad = false
    return;
  }
  console.log('does it escape')
  const target = document.body
  Object.keys(components).forEach((key) => {
    const behavior = components[key]
    behavior.on(target)
  })
})
