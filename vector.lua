local vector = {}

function vector.new(x, y)
    return {
        x = x or 0,
        y = y or 0,
    }
end

return vector
