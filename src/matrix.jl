eye(T,n,m) = Matrix{T}(LinearAlgebra.I,n,m)

Mat2(T) = Mat2x2(T) = zeros(T,2,2)
Mat3(T) = Mat3x3(T) = zeros(T,3,4)
Mat4(T) = Mat4x4(T) = zeros(T,4,4)

const Mat2f = const Mat2x2f = SMatrix{2,2,Float32}
const Mat3f = const Mat3x3f = SMatrix{3,3,Float32}
const Mat4f = const Mat4x4f = SMatrix{4,4,Float32}

const zerosMat4x4f = Mat4(Float32)
const eyeMat4x4f = eye(Float32,4,4)

export eye
export Mat2
export Mat3
export Mat4
export Mat2x2
export Mat3x3
export Mat4x4
export Mat4x4f
export zerosMat4x4f
export eyeMat4x4f