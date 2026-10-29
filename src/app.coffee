import { LitElement, html, unsafeCSS } from 'lit'
import styles from './app.css?inline'
import { TodoStore } from './store/todos.coffee'
import './components/counter-card.coffee'
import './components/todo-item.coffee'

FILTERS = ['all', 'active', 'done']

export class DemoApp extends LitElement
  constructor: ->
    super()
    @store = new TodoStore()
    @todos = @store.items
    @clicks = 0
    @draft = ''
    @filter = 'all'
    @theme = if window.matchMedia and window.matchMedia('(prefers-color-scheme: light)').matches
      'light'
    else
      'dark'
    @_unsubscribe = @store.subscribe @_sync

  connectedCallback: ->
    super()
    @_applyTheme()

  disconnectedCallback: ->
    super()
    @_unsubscribe?()

  # Store listener (bound so it survives being passed around).
  _sync: =>
    @todos = @store.items

  _applyTheme: ->
    document.documentElement.dataset.theme = @theme

  _visible: ->
    switch @filter
      when 'active' then @todos.filter (todo) -> not todo.done
      when 'done' then @todos.filter (todo) -> todo.done
      else @todos

  _openCount: ->
    @todos.filter((todo) -> not todo.done).length

  _doneCount: ->
    @todos.filter((todo) -> todo.done).length

  _addTodo: (event) =>
    event.preventDefault()
    todo = @store.add @draft
    return unless todo
    @draft = ''
    @filter = 'all'

  _onDraft: (event) =>
    @draft = event.target.value

  _setFilter: (filter) =>
    @filter = filter

  _onToggle: (event) =>
    @store.toggle event.detail.id

  _onRemove: (event) =>
    @store.remove event.detail.id

  _clearDone: =>
    @store.clearCompleted()

  _onCounter: (event) =>
    @clicks = event.detail.count

  _toggleTheme: =>
    @theme = if @theme is 'dark' then 'light' else 'dark'
    @_applyTheme()

  render: ->
    `html\`
      <div class="page">
        <header class="hero">
          <div class="badges">
            <span class="badge"><b>Lit</b> 3</span>
            <span class="badge"><b>CoffeeScript</b> 2</span>
            <span class="badge"><b>Vite</b> 6</span>
          </div>
          <h1>Reactive components,<br /><em>brewed</em> in CoffeeScript.</h1>
          <p class="lede">
            Lit provides the reactive web components, CoffeeScript keeps the source
            terse, and Vite compiles every <code>.coffee</code> module on demand with
            instant dev reloads.
          </p>
          <button class="theme" @click=${this._toggleTheme}>
            ${this.theme === 'dark' ? '☀️ Switch to light' : '🌙 Switch to dark'}
          </button>
        </header>

        <section class="grid">
          <counter-card
            label="Coffee poured"
            .count=${this.clicks}
            @count-changed=${this._onCounter}
          ></counter-card>

          <article class="panel">
            <header class="panel-head">
              <h2>Todos</h2>
              <span class="pill">${this._openCount()} open</span>
            </header>

            <form @submit=${this._addTodo}>
              <input
                .value=${this.draft}
                @input=${this._onDraft}
                placeholder="What needs doing?"
                aria-label="New todo"
              />
              <button type="submit">Add</button>
            </form>

            <div class="filters" role="group" aria-label="Filter todos">
              ${FILTERS.map((filter) => html\`
                <button
                  class=${this.filter === filter ? 'chip is-active' : 'chip'}
                  @click=${() => this._setFilter(filter)}
                >${filter}</button>
              \`)}
            </div>

            <div class="list" role="list">
              ${this._visible().length === 0
                ? html\`<p class="empty">Nothing here yet. Add your first task above.</p>\`
                : this._visible().map((todo) => html\`
                    <todo-item
                      .todo=${todo}
                      @todo-toggle=${this._onToggle}
                      @todo-remove=${this._onRemove}
                    ></todo-item>
                  \`)}
            </div>

            <footer class="panel-foot">
              <span>${this._doneCount()} completed</span>
              <button class="link" @click=${this._clearDone}>Clear completed</button>
            </footer>
          </article>
        </section>

        <footer class="page-foot">
          <span>Lit 3 &middot; CoffeeScript 2 &middot; Vite 6</span>
          <span>Zero decorators. Zero JSX. One build tool.</span>
        </footer>
      </div>
    \``

DemoApp.properties =
  clicks: { type: Number, state: true }
  draft: { type: String, state: true }
  filter: { type: String, state: true }
  theme: { type: String, state: true }
  todos: { type: Array, state: true }

DemoApp.styles = [unsafeCSS(styles)]

customElements.define 'demo-app', DemoApp
