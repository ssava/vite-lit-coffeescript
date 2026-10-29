# A tiny observable store. Plain CoffeeScript, no framework involved.
export class TodoStore
  constructor: (initial = []) ->
    @items = initial.slice()
    @listeners = new Set()

  subscribe: (listener) ->
    @listeners.add listener
    =>
      @listeners.delete listener

  add: (text) ->
    text = text.trim()
    return null if text is ''
    todo =
      id: crypto.randomUUID()
      text: text
      done: false
      createdAt: Date.now()
    @items = [todo, @items...]
    @_emit()
    todo

  toggle: (id) ->
    @items = @items.map (todo) ->
      return { ...todo, done: not todo.done } if todo.id is id
      todo
    @_emit()

  remove: (id) ->
    @items = @items.filter (todo) -> todo.id isnt id
    @_emit()

  clearCompleted: ->
    @items = @items.filter (todo) -> not todo.done
    @_emit()

  remaining: -> @items.filter((todo) -> not todo.done).length

  completed: -> @items.filter((todo) -> todo.done).length

  _emit: ->
    listener @items for listener from @listeners
    return
