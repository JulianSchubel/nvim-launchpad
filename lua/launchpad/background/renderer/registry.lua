local Registry = {}

Registry._renderers = {}

function Registry.register(name, factory)
    Registry._renderers[name] = factory
end

function Registry.get(name)
    return Registry._renderers[name]
end

function Registry.create(name)
    local factory = Registry.get(name)
    if factory then
        return factory()
    end
end

function Registry.has(name)
    return Registry._renderers[name] ~= nil
end

return Registry
