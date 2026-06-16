import { Controller } from "@hotwired/stimulus"

// Progressive-enhancement scroll reveal for the marketing pages.
// Only activates when JS + IntersectionObserver are available and the user
// hasn't asked to reduce motion — otherwise content stays fully visible.
export default class extends Controller {
  connect() {
    if (typeof IntersectionObserver === "undefined") return
    if (window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches) return

    const selector = ".mk-card, .mk-feature, .mk-grid > *, .mk-eyebrow, .mk-h1, .mk-h2, .mk-lead, .mk-stat__num, .mk-cat"
    const els = Array.from(this.element.querySelectorAll(selector))
    if (!els.length) return

    // Gate the hidden initial state on this class so no-JS = visible.
    this.element.classList.add("reveal-on")

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-in")
          this.observer.unobserve(entry.target)
        }
      })
    }, { threshold: 0.08, rootMargin: "0px 0px -40px 0px" })

    const seen = new Set()
    els.forEach((el) => {
      if (seen.has(el)) return
      seen.add(el)
      el.classList.add("mk-reveal")
      const idx = Math.min(this.#siblingIndex(el), 6)
      if (idx > 0) el.style.transitionDelay = `${idx * 70}ms`
      this.observer.observe(el)
    })
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  #siblingIndex(el) {
    let i = 0
    let sib = el
    while ((sib = sib.previousElementSibling) !== null) i++
    return i
  }
}
