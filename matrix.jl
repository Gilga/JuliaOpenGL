Mat2x2(T) = T[
  0 0
  0 0
]

Mat3x3(T) = T[
  0 0 0
  0 0 0
  0 0 0
]

Mat4x4(T) = T[
  0 0 0 0
  0 0 0 0
  0 0 0 0
  0 0 0 0
]

const Mat4x4f = SMatrix{4,4,Float32}

const zerosMat4x4f = Mat4x4(Float32)
const eyeMat4x4f = eye(zerosMat4x4f)