__precompile__(false)

module DefaultModelData

const DATA_DUMMY = Float32[0,0,0]
export DATA_DUMMY

const DATA_CUBE = Float32[
  # Bottom
  -1.0, -1.0, -1.0,
  1.0, -1.0, -1.0,
  -1.0, -1.0, 1.0,
  1.0, -1.0, -1.0,
  1.0, -1.0, 1.0,
  -1.0, -1.0, 1.0,

  # Top
  -1.0, 1.0, -1.0,
  -1.0, 1.0, 1.0,
  1.0, 1.0, -1.0,
  1.0, 1.0, -1.0,
  -1.0, 1.0, 1.0,
  1.0, 1.0, 1.0,

  # Front
  -1.0, -1.0, 1.0,
  1.0, -1.0, 1.0,
  -1.0, 1.0, 1.0,
  1.0, -1.0, 1.0,
  1.0, 1.0, 1.0,
  -1.0, 1.0, 1.0,

  # Back
  -1.0, -1.0, -1.0,
  -1.0, 1.0, -1.0,
  1.0, -1.0, -1.0,
  1.0, -1.0, -1.0,
  -1.0, 1.0, -1.0,
  1.0, 1.0, -1.0,

  # Left
  -1.0, -1.0, 1.0,
  -1.0, 1.0, -1.0,
  -1.0, -1.0, -1.0,
  -1.0, -1.0, 1.0,
  -1.0, 1.0, 1.0,
  -1.0, 1.0, -1.0,

  # Right
  1.0, -1.0, 1.0,
  1.0, -1.0, -1.0,
  1.0, 1.0, -1.0,
  1.0, -1.0, 1.0,
  1.0, 1.0, -1.0,
  1.0, 1.0, 1.0,
]

export DATA_CUBE

const DATA_CUBE_VERTEX = Float32[
  1f0,  1,  1,  # 0
  -1,  1,  1,   # 1
  -1, -1,  1,   # 2
  1, -1,  1,    # 3
  1, -1, -1,    # 4
  -1, -1, -1,   # 5
  -1,  1, -1,   # 6
  1,  1, -1,    # 7
]

export DATA_CUBE_VERTEX

const DATA_CUBE_INDEX = UInt32[
  0, 1, 2, 2, 3, 0, # Front face
  7, 4, 5, 5, 6, 7, # Back face
  6, 5, 2, 2, 1, 6, # Left face
  7, 0, 3, 3, 4, 7, # Right face
  7, 6, 1, 1, 0, 7, # Top face
  3, 2, 5, 5, 4, 3  # Bottom face
]

export DATA_CUBE_INDEX

const DATA_PLANE_VERTEX  = Float32[
  1f0,  0,  1,  # 0
  1, 0, -1,     # 1
  -1,  0,  1,   # 2
  -1, 0, -1     # 3
]

export DATA_PLANE_VERTEX

const DATA_PLANE_INDEX = UInt32[
  0, 1, 2, 3 #GL_TRIANGLE_STRIP
  #0, 1, 2, 2, 1, 3 #GL_TRIANGLES
]

export DATA_PLANE_INDEX

const DATA_PLANE2D_VERTEX_STRIP = Float32[-1, -1, 1, -1, -1, 1, 1, 1]

export DATA_PLANE2D_VERTEX_STRIP

end #DefaultModelData
