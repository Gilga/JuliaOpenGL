# mesh.jl

Transform

MeshArray

MeshData

setAttributes(this::MeshArray, program, attrb)

createBuffers(this::MeshData)

setAttributes(this::MeshData, program)

setDrawArray(this::MeshData, key::Symbol)

setData(this::MeshArray, data, elems=0)

linkData(this::MeshData, args...)

upload(this::MeshArray)

upload(this::MeshData)

upload(this::MeshData, key::Symbol, data::AbstractArray)
