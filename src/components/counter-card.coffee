import { LitElement, html, unsafeCSS } from 'lit'
import styles from './counter-card.css?inline'

# CoffeeScript cannot express tagged template literals directly, so Lit's
# html`...` template is written inside a JavaScript block delimited by
# backticks. Everything outside that block - state, events, lifecycle - is
# ordinary CoffeeScript.
export class CounterCard extends LitElement
  constructor: ->
    super()
    @label = 'Counter'
    @count = 0
    @step = 1

  _bump: (delta) =>
    @count = Math.max 0, @count + delta
    @dispatchEvent new CustomEvent 'count-changed',
      detail: { count: @count }
      bubbles: true
      composed: true

  _reset: =>
    @count = 0
    @dispatchEvent new CustomEvent 'count-changed',
      detail: { count: @count }
      bubbles: true
      composed: true

  render: ->
    `html\`
      <div class="card">
        <div class="head">
          <span class="eyebrow">${this.label}</span>
          <span class="value" part="value">${this.count}</span>
        </div>
        <div class="controls">
          <button
            class="ghost"
            aria-label="Decrease"
            @click=${() => this._bump(-1)}
            ?disabled=${this.count === 0}
          >&minus;</button>
          <button aria-label="Increase" @click=${() => this._bump(1)}>+</button>
          <button class="ghost" @click=${this._reset} ?disabled=${this.count === 0}>reset</button>
        </div>
        <p class="hint">Dispatches <code>count-changed</code> across the shadow boundary.</p>
      </div>
    \``

CounterCard.properties =
  label: { type: String }
  count: { type: Number }
  step: { type: Number }

CounterCard.styles = [unsafeCSS(styles)]

customElements.define 'counter-card', CounterCard
