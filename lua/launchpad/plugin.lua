local AnimationRegistry =
  require("launchpad.background.animation.registry")

local RendererRegistry =
  require("launchpad.background.renderer.registry")

local PluginAPI = {}

-- Animations ----------------------------------------------------

function PluginAPI.register_animation(name, factory)
  assert(type(name) == "string", "animation name must be string")
  assert(type(factory) == "function", "animation factory must be function")

  AnimationRegistry.register(name, factory)
end

function PluginAPI.has_animation(name)
  return AnimationRegistry.has(name)
end

-- Renderers -----------------------------------------------------

function PluginAPI.register_renderer(name, factory)
  assert(type(name) == "string", "renderer name must be string")
  assert(type(factory) == "function", "renderer factory must be function")

  RendererRegistry.register(name, factory)
end

function PluginAPI.has_renderer(name)
  return RendererRegistry.has(name)
end

return PluginAPI
