import { defineConfig } from 'vite'
import CoffeeScript from 'coffeescript'

/**
 * Minimal Vite plugin that compiles `.coffee` files on demand.
 *
 * It runs in the `pre` phase so the rest of Vite (esbuild, dep scanning,
 * HMR) sees plain JavaScript, exactly as if the file had been written in JS.
 */
function coffeePlugin() {
  return {
    name: 'vite-plugin-coffeescript',
    enforce: 'pre',

    transform(source, id) {
      if (!id.endsWith('.coffee')) return null

      const compiled = CoffeeScript.compile(source, {
        bare: true,
        filename: id,
        sourceMap: true,
      })

      return {
        code: compiled.js,
        map: compiled.v3SourceMap ? JSON.parse(compiled.v3SourceMap) : null,
      }
    },
  }
}

export default defineConfig({
  plugins: [coffeePlugin()],
  server: {
    port: 5173,
  },
  test: {
    environment: 'happy-dom',
    include: ['src/**/*.test.coffee'],
  },
})
