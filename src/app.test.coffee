import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import './app.coffee'

mount = ->
  document.body.innerHTML = '<demo-app></demo-app>'
  app = document.querySelector 'demo-app'
  await app.updateComplete
  app

addTodo = (app, text) ->
  input = app.shadowRoot.querySelector 'form input'
  input.value = text
  input.dispatchEvent new Event 'input', bubbles: true
  app.shadowRoot.querySelector('form').dispatchEvent(
    new Event 'submit', bubbles: true, cancelable: true
  )
  await app.updateComplete

describe 'demo-app', ->
  beforeEach ->
    document.body.innerHTML = ''

  afterEach ->
    document.body.innerHTML = ''

  it 'renders the hero, counter and todo panel', ->
    app = await mount()
    expect(app.shadowRoot.querySelector('h1').textContent).toContain 'CoffeeScript'
    expect(app.shadowRoot.querySelector('counter-card')).toBeTruthy()
    expect(app.shadowRoot.querySelector('.panel')).toBeTruthy()
    expect(app.shadowRoot.querySelectorAll('.chip').length).toBe 3

  it 'reacts to events dispatched by the child counter', ->
    app = await mount()
    card = app.shadowRoot.querySelector 'counter-card'

    card.shadowRoot.querySelector('button[aria-label="Increase"]').click()
    await card.updateComplete
    await app.updateComplete

    expect(card.count).toBe 1
    expect(app.clicks).toBe 1
    expect(app.shadowRoot.querySelector('counter-card').count).toBe 1

  it 'adds, completes and removes todos through the store', ->
    app = await mount()

    await addTodo app, 'Grind beans'
    await addTodo app, 'Brew coffee'

    items = app.shadowRoot.querySelectorAll 'todo-item'
    expect(items.length).toBe 2
    expect(items[0].todo.text).toBe 'Brew coffee'
    expect(app.shadowRoot.querySelector('.empty')).toBeNull()

    items[0].shadowRoot.querySelector('input[type="checkbox"]').click()
    await app.updateComplete
    expect(app.store.completed()).toBe 1

    app.shadowRoot.querySelector('todo-item').shadowRoot.querySelector('.remove').click()
    await app.updateComplete
    expect(app.shadowRoot.querySelectorAll('todo-item').length).toBe 1

  it 'filters todos with the chips', ->
    app = await mount()
    await addTodo app, 'One'
    await addTodo app, 'Two'

    app.shadowRoot.querySelector('todo-item').shadowRoot.querySelector('input').click()
    await app.updateComplete

    app.shadowRoot.querySelectorAll('.chip')[1].click() # active
    await app.updateComplete
    expect(app.shadowRoot.querySelectorAll('todo-item').length).toBe 1

    app.shadowRoot.querySelectorAll('.chip')[2].click() # done
    await app.updateComplete
    expect(app.shadowRoot.querySelectorAll('todo-item').length).toBe 1
    expect(app.shadowRoot.querySelector('todo-item').todo.done).toBe true

  it 'toggles the document theme', ->
    app = await mount()
    start = app.theme
    app.shadowRoot.querySelector('button.theme').click()
    await app.updateComplete

    expect(app.theme).not.toBe start
    expect(document.documentElement.dataset.theme).toBe app.theme
