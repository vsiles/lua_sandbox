local vector = {}

function vector.new(x, y)
    return {
        x = x or 0,
        y = y or 0,
    }
end

function vector.sub(v1, v2)
    return {
        x = v1.x - v2.x,
        y = v1.y - v2.y,
    }
end

function vector.length2(v)
    return (v.x * v.x) + (v.y * v.y)
end

function vector.length(v)
    local l2 = vector.length2(v)
    return math.sqrt(l2)
end

function vector.eq(v1, v2)
    return (v1.x == v2.x) and (v1.y == v2.y)
end

return vector
