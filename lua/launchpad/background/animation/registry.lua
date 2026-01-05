local Registry = {}

Registry._animations = {}

function Registry.register(name, factory)
    Registry._animations[name] = factory
end

function Registry.get(name)
    return Registry._animations[name]
end

function Registry.create(name)
    local factory = Registry.get(name)
    if factory then
        return factory()
    end
end

function Registry.has(name)
    return Registry._animations[name] ~= nil
end

return Registry
