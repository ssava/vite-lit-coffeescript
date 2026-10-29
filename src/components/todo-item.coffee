import { LitElement, html, unsafeCSS } from 'lit'
import styles from './todo-item.css?inline'

export class TodoItem extends LitElement
  _toggle: =>
    @dispatchEvent new CustomEvent 'todo-toggle',
      detail: { id: @todo.id }
      bubbles: true
      composed: true

  _remove: =>
    @dispatchEvent new CustomEvent 'todo-remove',
      detail: { id: @todo.id }
      bubbles: true
      composed: true

  render: ->
    `html\`
      <div
        class="row ${this.todo?.done ? 'done' : ''}"
        role="listitem"
      >
        <label class="check">
          <input
            type="checkbox"
            .checked=${this.todo?.done}
            @change=${this._toggle}
            aria-label="Toggle ${this.todo?.text}"
          />
          <span class="box" aria-hidden="true"></span>
        </label>
        <span class="text">${this.todo?.text}</span>
        <button
          class="remove"
          @click=${this._remove}
          aria-label="Remove ${this.todo?.text}"
        >&times;</button>
      </div>
    \``

TodoItem.properties =
  todo: { type: Object }

TodoItem.styles = [unsafeCSS(styles)]

customElements.define 'todo-item', TodoItem
