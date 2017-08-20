local vector = {}

function vector.new(x, y)
    return {
        x = x or 0,
        y = y or 0,
    }
end

function vector.eq(v1, v2)
    return (v1.x == v2.x) and (v1.y == v2.y)
end

return vector
