module GLLists

using ModernGL

export GL_QUERY_BUFFER
export GL_SHADER_BINARY_FORMAT_SPIR_V_ARB

export DEFAULT_SHADER_VERSION
export DEFAULT_SHADER_CODE

export CLIP_DISTANCE
export LIST_STATUS
export LIST_BUFFER
export LIST_OPTIONS
export LIST_COLOR_MASK
export LIST_COMPARE
export LIST_INFO
export LIST_SHADER
export LIST_DRAW_MODE
export LIST_ERROR
export LIST_TYPE
export LIST_TYPE_ELEMENTS
export LIST_TYPE_STRING

# missing constants
const GL_QUERY_BUFFER = convert(GLenum, 0x9192)
const GL_SHADER_BINARY_FORMAT_SPIR_V_ARB = convert(GLenum, 0x9551)

""" TODO """
const LIST_STATUS = Dict{Symbol,Dict{Symbol,Function}}(
	:SHADER		=> Dict{Symbol,Function}(:STATE => glGetShaderiv, :INFO => glGetShaderInfoLog),
	:PROGRAM	=> Dict{Symbol,Function}(:STATE => glGetProgramiv, :INFO => glGetProgramInfoLog),
)

const LIST_BUFFER = Dict{Symbol,GLenum}(
	:ARRAY_BUFFER								=> GL_ARRAY_BUFFER,
	:ATOMIC_COUNTER_BUFFER			=> GL_ATOMIC_COUNTER_BUFFER,
	:COPY_READ_BUFFER						=> GL_COPY_READ_BUFFER,
	:COPY_WRITE_BUFFER					=> GL_COPY_WRITE_BUFFER,
	:DISPATCH_INDIRECT_BUFFER		=> GL_DISPATCH_INDIRECT_BUFFER,
	:DRAW_INDIRECT_BUFFER				=> GL_DRAW_INDIRECT_BUFFER,
	:ELEMENT_ARRAY_BUFFER				=> GL_ELEMENT_ARRAY_BUFFER,
	:PIXEL_PACK_BUFFER					=> GL_PIXEL_PACK_BUFFER,
	:PIXEL_UNPACK_BUFFER				=> GL_PIXEL_UNPACK_BUFFER,
	:QUERY_BUFFER								=> GL_QUERY_BUFFER,
	:SHADER_STORAGE_BUFFER			=> GL_SHADER_STORAGE_BUFFER,
	:TEXTURE_BUFFER							=> GL_TEXTURE_BUFFER,
	:TRANSFORM_FEEDBACK_BUFFER	=> GL_TRANSFORM_FEEDBACK_BUFFER,
	:UNIFORM_BUFFER							=> GL_UNIFORM_BUFFER,
)

const CLIP_DISTANCE = [
	GL_CLIP_DISTANCE0,
	GL_CLIP_DISTANCE1,
	GL_CLIP_DISTANCE2,
	GL_CLIP_DISTANCE3,
	GL_CLIP_DISTANCE4,
	GL_CLIP_DISTANCE5,
	GL_CLIP_DISTANCE6,
	GL_CLIP_DISTANCE7,
	#GL_CLIP_DISTANCE8,
]

#	GL_CLIP_ORIGIN,
#	GL_CLIP_DEPTH_MODE
#	GL_CLIPPING_INPUT_PRIMITIVES_ARB
#	GL_CLIPPING_OUTPUT_PRIMITIVES_ARB

const LIST_OPTIONS = Dict{Symbol,GLuint}(
	:ALPHA_TEST                     => 0,                                # GL_ALPHA_TEST
	:AUTO_NORMAL                    => GL_AUTO_GENERATE_MIPMAP,          # GL_AUTO_NORMAL
	:BLEND                          => GL_BLEND,                         # GL_BLEND
	:CLIP_PLANEi                    => 0,                                # GL_CLIP_PLANEi
	:CLIP_DISTANCEi                 => 0,                                # GL_CLIP_DISTANCEi
	:COLOR_LOGIC_OP                 => GL_COLOR_LOGIC_OP,                # GL_COLOR_LOGIC_OP
	:COLOR_MATERIAL                 => 0,                                # GL_COLOR_MATERIAL
	:COLOR_SUM                      => 0,                                # GL_COLOR_SUM
	:COLOR_TABLE                    => 0,                                # GL_COLOR_TABLE
	:CONVOLUTION_1D                 => 0,                                # GL_CONVOLUTION_1D
	:CONVOLUTION_2D                 => 0,                                # GL_CONVOLUTION_2D
	:CULL_FACE                      => GL_CULL_FACE,                     # GL_CULL_FACE
	:DEBUG_OUTPUT                   => GL_DEBUG_OUTPUT,                  # GL_DEBUG_OUTPUT
	:DEBUG_OUTPUT_SYNCHRONOUS       => GL_DEBUG_OUTPUT_SYNCHRONOUS,      # GL_DEBUG_OUTPUT_SYNCHRONOUS
	:DEPTH_CLAMP                    => GL_DEPTH_CLAMP,                   # GL_DEPTH_CLAMP
	:DEPTH_TEST                     => GL_DEPTH_TEST,                    # GL_DEPTH_TEST
	:DITHER                         => GL_DITHER,                        # GL_DITHER
	:FOG                            => 0,                                # GL_FOG
	:FRAMEBUFFER_SRGB               => GL_FRAMEBUFFER_SRGB,              # GL_FRAMEBUFFER_SRGB
	:HISTOGRAM                      => 0,                                # GL_HISTOGRAM
	:INDEX_LOGIC_OP                 => 0,                                # GL_INDEX_LOGIC_OP
	:LIGHTi                         => 0,                                # GL_LIGHTi
	:LIGHTING                       => 0,                                # GL_LIGHTING
	:LINE_SMOOTH                    => GL_LINE_SMOOTH,                   # GL_LINE_SMOOTH
	:LINE_STIPPLE                   => 0,                                # GL_LINE_STIPPLE
	:MAP1_COLOR_4                   => 0,                                # GL_MAP1_COLOR_4
	:MAP1_INDEX                     => 0,                                # GL_MAP1_INDEX
	:MAP1_NORMAL                    => 0,                                # GL_MAP1_NORMAL
	:MAP1_TEXTURE_COORD_1           => 0,                                # GL_MAP1_TEXTURE_COORD_1
	:MAP1_TEXTURE_COORD_2           => 0,                                # GL_MAP1_TEXTURE_COORD_2
	:MAP1_TEXTURE_COORD_3           => 0,                                # GL_MAP1_TEXTURE_COORD_3
	:MAP1_TEXTURE_COORD_4           => 0,                                # GL_MAP1_TEXTURE_COORD_4
	:MAP1_VERTEX_3                  => 0,                                # GL_MAP1_VERTEX_3
	:MAP1_VERTEX_4                  => 0,                                # GL_MAP1_VERTEX_4
	:MAP2_COLOR_4                   => 0,                                # GL_MAP2_COLOR_4
	:MAP2_INDEX                     => 0,                                # GL_MAP2_INDEX
	:MAP2_NORMAL                    => 0,                                # GL_MAP2_NORMAL
	:MAP2_TEXTURE_COORD_1           => 0,                                # GL_MAP2_TEXTURE_COORD_1
	:MAP2_TEXTURE_COORD_2           => 0,                                # GL_MAP2_TEXTURE_COORD_2
	:MAP2_TEXTURE_COORD_3           => 0,                                # GL_MAP2_TEXTURE_COORD_3
	:MAP2_TEXTURE_COORD_4           => 0,                                # GL_MAP2_TEXTURE_COORD_4
	:MAP2_VERTEX_3                  => 0,                                # GL_MAP2_VERTEX_3
	:MAP2_VERTEX_4                  => 0,                                # GL_MAP2_VERTEX_4
	:MINMAX                         => 0,                                # GL_MINMAX
	:MULTISAMPLE                    => GL_MULTISAMPLE,                   # GL_MULTISAMPLE
	:NORMALIZE                      => 0,                                # GL_NORMALIZE
	:POINT_SMOOTH                   => 0,                                # GL_POINT_SMOOTH
	:POINT_SPRITE                   => 0,                                # GL_POINT_SPRITE
	:POLYGON_OFFSET_FILL            => GL_POLYGON_OFFSET_FILL,           # GL_POLYGON_OFFSET_FILL
	:POLYGON_OFFSET_LINE            => GL_POLYGON_OFFSET_LINE,           # GL_POLYGON_OFFSET_LINE
	:POLYGON_OFFSET_POINT           => GL_POLYGON_OFFSET_POINT,          # GL_POLYGON_OFFSET_POINT
	:POLYGON_SMOOTH                 => GL_POLYGON_SMOOTH,                # GL_POLYGON_SMOOTH
	:POLYGON_STIPPLE                => 0,                                # GL_POLYGON_STIPPLE
	:POST_COLOR_MATRIX_COLOR_TABLE  => 0,                                # GL_POST_COLOR_MATRIX_COLOR_TABLE
	:POST_CONVOLUTION_COLOR_TABLE   => 0,                                # GL_POST_CONVOLUTION_COLOR_TABLE
	:PRIMITIVE_RESTART              => GL_PRIMITIVE_RESTART,             # GL_PRIMITIVE_RESTART
	:PRIMITIVE_RESTART_FIXED_INDEX  => GL_PRIMITIVE_RESTART_FIXED_INDEX, # GL_PRIMITIVE_RESTART_FIXED_INDEX
	:PROGRAM_POINT_SIZE             => GL_PROGRAM_POINT_SIZE,            # GL_PROGRAM_POINT_SIZE
	:RASTERIZER_DISCARD             => GL_RASTERIZER_DISCARD,            # GL_RASTERIZER_DISCARD
	:RESCALE_NORMAL                 => 0,                                # GL_RESCALE_NORMAL
	:SAMPLE_ALPHA_TO_COVERAGE       => GL_SAMPLE_ALPHA_TO_COVERAGE,      # GL_SAMPLE_ALPHA_TO_COVERAGE
	:SAMPLE_ALPHA_TO_ONE            => GL_SAMPLE_ALPHA_TO_ONE,           # GL_SAMPLE_ALPHA_TO_ONE
	:SAMPLE_COVERAGE                => GL_SAMPLE_COVERAGE,               # GL_SAMPLE_COVERAGE
	:SAMPLE_SHADING                 => GL_SAMPLE_SHADING,                # GL_SAMPLE_SHADING
	:SAMPLE_MASK                    => GL_SAMPLE_MASK,                   # GL_SAMPLE_MASK
	:SEPARABLE_2D                   => 0,                                # GL_SEPARABLE_2D
	:SCISSOR_TEST                   => GL_SCISSOR_TEST,                  # GL_SCISSOR_TEST
	:STENCIL_TEST                   => GL_STENCIL_TEST,                  # GL_STENCIL_TEST
	:TEXTURE_1D                     => GL_TEXTURE_1D,                    # GL_TEXTURE_1D
	:TEXTURE_2D                     => GL_TEXTURE_2D,                    # GL_TEXTURE_2D
	:TEXTURE_3D                     => GL_TEXTURE_3D,                    # GL_TEXTURE_3D
	:TEXTURE_CUBE_MAP               => GL_TEXTURE_CUBE_MAP,              # GL_TEXTURE_CUBE_MAP
	:TEXTURE_CUBE_MAP_SEAMLESS      => GL_TEXTURE_CUBE_MAP_SEAMLESS,     # GL_TEXTURE_CUBE_MAP_SEAMLESS
	:TEXTURE_GEN_Q                  => 0,                                # GL_TEXTURE_GEN_Q
	:TEXTURE_GEN_R                  => 0,                                # GL_TEXTURE_GEN_R
	:TEXTURE_GEN_S                  => 0,                                # GL_TEXTURE_GEN_S
	:TEXTURE_GEN_T                  => 0,                                # GL_TEXTURE_GEN_T
	:VERTEX_PROGRAM_POINT_SIZE      => GL_VERTEX_PROGRAM_POINT_SIZE,     # GL_VERTEX_PROGRAM_POINT_SIZE
	:VERTEX_PROGRAM_TWO_SIDE        => 0,                                # GL_VERTEX_PROGRAM_TWO_SIDE
)

const LIST_COLOR_MASK = Dict{Symbol,GLuint}(
	:SRC_COLOR                 => GL_SRC_COLOR,
	:ONE_MINUS_SRC_COLOR       => GL_ONE_MINUS_SRC_COLOR,
	:DST_COLOR                 => GL_DST_COLOR,
	:ONE_MINUS_DST_COLOR       => GL_ONE_MINUS_DST_COLOR,
	:SRC_ALPHA                 => GL_SRC_ALPHA,
	:ONE_MINUS_SRC_ALPHA       => GL_ONE_MINUS_SRC_ALPHA,
	:DST_ALPHA                 => GL_DST_ALPHA,
	:ONE_MINUS_DST_ALPHA       => GL_ONE_MINUS_DST_ALPHA,
	:CONSTANT_COLOR            => GL_CONSTANT_COLOR,
	:ONE_MINUS_CONSTANT_COLOR  => GL_ONE_MINUS_CONSTANT_COLOR,
	:CONSTANT_ALPHA            => GL_CONSTANT_ALPHA,
	:ONE_MINUS_CONSTANT_ALPHA  => GL_ONE_MINUS_CONSTANT_ALPHA,
	:SRC_ALPHA_SATURATE        => GL_SRC_ALPHA_SATURATE,
	:SRC1_COLOR                => GL_SRC1_COLOR,
	:ONE_MINUS_SRC1_COLOR      => GL_ONE_MINUS_SRC1_COLOR,
	:SRC1_ALPHA                => GL_SRC1_ALPHA,
	:ONE_MINUS_SRC1_ALPHA      => GL_ONE_MINUS_SRC1_ALPHA,
)

const LIST_COMPARE = Dict{Symbol,GLuint}(
	:NEVER     => GL_NEVER,
	:LESS      => GL_LESS,
	:EQUAL     => GL_EQUAL,
	:LEQUAL    => GL_LEQUAL,
	:GREATER   => GL_GREATER,
	:NOTEQUAL  => GL_NOTEQUAL,
	:GEQUAL    => GL_GEQUAL,
	:ALWAYS    => GL_ALWAYS,
)

const LIST_INFO = Dict{Symbol,GLuint}(
	:RENDERER =>                 GL_RENDERER,
	:VENDOR =>                   GL_VENDOR,
	:VERSION =>                  GL_VERSION,
	:SHADING_LANGUAGE_VERSION => GL_SHADING_LANGUAGE_VERSION,
	:EXTENSIONS =>               GL_EXTENSIONS,
)

const DEFAULT_SHADER_VERSION = 130

function DEFAULT_SHADER_CODE(typ::Symbol)
	code = LIST_SHADER[typ][:CODE]
	string("#version ",DEFAULT_SHADER_VERSION,"\n",code[1],"\n",code[2],"\nvoid main(){\n",code[3],"\n}")
end

const LIST_SHADER = Dict(
	:VERTEX           => Dict(:TYPE => GLuint(GL_VERTEX_SHADER),					:EXT => "vert", :CODE => ("in vec3 iVertex; uniform mat4 iMVP = mat4(vec4(1,0,0,0),vec4(0,1,0,0),vec4(0,0,1,0),vec4(0,0,0,1));", "", "gl_Position = iMVP * vec4(iVertex,1);")),
	:FRAGMENT         => Dict(:TYPE => GLuint(GL_FRAGMENT_SHADER),				:EXT => "frag", :CODE => ("", "out vec4 oFragColor;", "oFragColor=vec4(vec3(0.5),1.0);")),
	:TESS_CONTROL			=> Dict(:TYPE => GLuint(GL_TESS_CONTROL_SHADER),		:EXT => "tesc", :CODE => ("uniform uint iTessLevel = 1;", "layout (vertices = 3) out;", "#define ID gl_InvocationID\n if (ID == 0) for(int i=0; i<3; ++i){	if(i<2) gl_TessLevelInner[i] = iTessLevel; gl_TessLevelOuter[i] = iTessLevel; }; gl_out[ID].gl_Position = gl_in[ID].gl_Position;")),
	:TESS_EVALUATION	=> Dict(:TYPE => GLuint(GL_TESS_EVALUATION_SHADER),	:EXT => "tese", :CODE => ("layout (triangles, equal_spacing, ccw) in;", "", "gl_Position = vec4(gl_in[0].gl_Position.xyz * gl_TessCoord.x + gl_in[1].gl_Position.xyz * gl_TessCoord.y + gl_in[2].gl_Position.xyz * gl_TessCoord.z,1.0);")),
	:GEOMETRY         => Dict(:TYPE => GLuint(GL_GEOMETRY_SHADER),				:EXT => "geom",	:CODE => ("layout(triangles) in;", "layout(triangle_strip, max_vertices=3) out;", "for(int i=0; i<gl_in.length(); ++i){ gl_Position = gl_in[i].gl_Position; EmitVertex(); }; EndPrimitive();")),
	:COMPUTE          => Dict(:TYPE => GLuint(GL_COMPUTE_SHADER),					:EXT => "comp",	:CODE => ("", "", "")),
)

const LIST_DRAW_MODE = Dict{Symbol,GLuint}(
	:POINTS										=> GL_POINTS,										#0x0000
	:LINES										=> GL_LINE,											#0x0001
	:LINE_LOOP								=> GL_LINE_LOOP,								#0x0002
	:LINE_STRIP     					=> GL_LINE_STRIP,								#0x0003
	:TRIANGLES 								=> GL_TRIANGLES,								#0x0004
	:TRIANGLE_STRIP  					=> GL_TRIANGLE_STRIP,						#0x0005
	:TRIANGLE_FAN							=> GL_TRIANGLE_FAN,							#0x0006
	:QUADS										=> GL_QUADS,										#0x0007
	:QUAD_STRIP								=> GL_QUAD_STRIP,								#0x0008 (deprecated since OpenGL3)
	:POLYGON									=> GL_POLYGON,									#0x0009 (deprecated since OpenGL3)
	:LINES_ADJACENCY					=> GL_LINES_ADJACENCY,					#0x000A
	:LINE_STRIP_ADJACENCY			=> GL_LINE_STRIP_ADJACENCY,			#0x000B
	:TRIANGLES_ADJACENCY			=> GL_TRIANGLES_ADJACENCY,			#0x000C
	:TRIANGLE_STRIP_ADJACENCY	=> GL_TRIANGLE_STRIP_ADJACENCY,	#0x000D
	:PATCHES 									=> GL_PATCHES,									#0x000E
)

const LIST_ERROR = Dict{GLuint,AbstractString}(
	GL_NO_ERROR											 =>	"",
	GL_INVALID_ENUM									 =>	"INVALID_ENUM: An unacceptable value is specified for an enumerated argument. The offending command is ignored and has no other side effect than to set the error flag.",
	GL_INVALID_VALUE								 =>	"INVALID_VALUE: A numeric argument is out of range. The offending command is ignored and has no other side effect than to set the error flag.",
	GL_INVALID_OPERATION						 =>	"INVALID_OPERATION: The specified operation is not allowed in the current state. The offending command is ignored and has no other side effect than to set the error flag.",
	GL_INVALID_FRAMEBUFFER_OPERATION => "INVALID_FRAMEBUFFER_OPERATION: The framebuffer object is not complete. The offending command is ignored and has no other side effect than to set the error flag.",
	GL_OUT_OF_MEMORY								 =>	"OUT_OF_MEMORY: There is not enough memory left to execute the command. The state of the GL is undefined, except for the state of the error flags, after this error is recorded.",
	GL_STACK_UNDERFLOW							 =>	"STACK_UNDERFLOW",
	GL_STACK_OVERFLOW								 =>	"STACK_OVERFLOW",
)

const LIST_TYPE = Dict{DataType,GLuint}(
	Bool => GL_BOOL,
	Int8 => GL_BYTE,
	Int16 => GL_SHORT,
	Int32 => GL_INT, #gl_low_int, gl_medium_int, gl_high_int
	Int64 => GL_INT, # no 64 bit support
	Int128 => GL_INT, # no 128 bit support
	UInt8 => GL_UNSIGNED_BYTE,
	UInt16 => GL_UNSIGNED_SHORT,
	UInt32 => GL_UNSIGNED_INT,
	UInt64 => GL_UNSIGNED_INT, # no 64 bit support
	UInt128 => GL_UNSIGNED_INT, # no 128 bit support
	Float16 => GL_HALF_FLOAT,
	Float32 => GL_FLOAT,
	Float64 => GL_DOUBLE,
)

const LIST_TYPE_ELEMENTS = Dict{GLuint,UInt32}(
	# Float
	GL_FLOAT =>      1,
	GL_FLOAT_VEC2 => 2,
	GL_FLOAT_VEC3 => 3,
	GL_FLOAT_VEC4 => 4,

	# Doubles
	GL_DOUBLE =>      1,
	GL_DOUBLE_VEC2 => 2,
	GL_DOUBLE_VEC3 => 3,
	GL_DOUBLE_VEC4 => 4,

	# Int
	GL_INT =>      1,
	GL_INT_VEC2 => 2,
	GL_INT_VEC3 => 3,
	GL_INT_VEC4 => 4,

	# Unsigned Int
	GL_UNSIGNED_INT =>      1,
	GL_UNSIGNED_INT_VEC2 => 2,
	GL_UNSIGNED_INT_VEC3 => 3,
	GL_UNSIGNED_INT_VEC4 => 4,

	# Bool
	GL_BOOL =>      1,
	GL_BOOL_VEC2 => 2,
	GL_BOOL_VEC3 => 3,
	GL_BOOL_VEC4 => 4,

	# Float Matrix
	GL_FLOAT_MAT2 =>   4,
	GL_FLOAT_MAT3 =>   9,
	GL_FLOAT_MAT4 =>   16,
	GL_FLOAT_MAT2x3 => 6,
	GL_FLOAT_MAT2x4 => 8,
	GL_FLOAT_MAT3x2 => 6,
	GL_FLOAT_MAT3x4 => 12,
	GL_FLOAT_MAT4x2 => 8,
	GL_FLOAT_MAT4x3 => 12,

	# Double Matrix
	GL_DOUBLE_MAT2 =>   4,
	GL_DOUBLE_MAT3 =>   9,
	GL_DOUBLE_MAT4 =>   16,
	GL_DOUBLE_MAT2x3 => 6,
	GL_DOUBLE_MAT2x4 => 8,
	GL_DOUBLE_MAT3x2 => 6,
	GL_DOUBLE_MAT3x4 => 12,
	GL_DOUBLE_MAT4x2 => 8,
	GL_DOUBLE_MAT4x3 => 12,
)

const LIST_TYPE_STRING = Dict{GLuint,AbstractString}(
	# Float
	GL_FLOAT =>      "float",
	GL_FLOAT_VEC2 => "vec2f",
	GL_FLOAT_VEC3 => "vec3f",
	GL_FLOAT_VEC4 => "vec4f",

	# Doubles
	GL_DOUBLE =>      "double",
	GL_DOUBLE_VEC2 => "vec2d",
	GL_DOUBLE_VEC3 => "vec3d",
	GL_DOUBLE_VEC4 => "vec4d",

	# Int
	GL_INT =>      "int",
	GL_INT_VEC2 => "vec2i",
	GL_INT_VEC3 => "vec3i",
	GL_INT_VEC4 => "vec4i",

	# Unsigned Int
	GL_UNSIGNED_INT =>      "uint",
	GL_UNSIGNED_INT_VEC2 => "vec2u",
	GL_UNSIGNED_INT_VEC3 => "vec3u",
	GL_UNSIGNED_INT_VEC4 => "vec4u",

	# Bool
	GL_BOOL =>      "bool",
	GL_BOOL_VEC2 => "vec2b",
	GL_BOOL_VEC3 => "vec3b",
	GL_BOOL_VEC4 => "vec4b",

	# Float Matrix
	GL_FLOAT_MAT2 =>   "mat2f",
	GL_FLOAT_MAT3 =>   "mat3f",
	GL_FLOAT_MAT4 =>   "mat4f",
	GL_FLOAT_MAT2x3 => "mat2x3f",
	GL_FLOAT_MAT2x4 => "mat2x4f",
	GL_FLOAT_MAT3x2 => "mat3x2f",
	GL_FLOAT_MAT3x4 => "mat3x4f",
	GL_FLOAT_MAT4x2 => "mat4x2f",
	GL_FLOAT_MAT4x3 => "mat4x3f",

	# Double Matrix
	GL_DOUBLE_MAT2 =>   "mat2d",
	GL_DOUBLE_MAT3 =>   "mat3d",
	GL_DOUBLE_MAT4 =>   "mat4d",
	GL_DOUBLE_MAT2x3 => "mat2x3d",
	GL_DOUBLE_MAT2x4 => "mat2x4d",
	GL_DOUBLE_MAT3x2 => "mat3x2d",
	GL_DOUBLE_MAT3x4 => "mat3x4d",
	GL_DOUBLE_MAT4x2 => "mat4x2d",
	GL_DOUBLE_MAT4x3 => "mat4x3d",

	# Sampler
	GL_SAMPLER_1D =>                   "sampler1D",
	GL_SAMPLER_2D =>                   "sampler2D",
	GL_SAMPLER_3D =>                   "sampler3D",
	GL_SAMPLER_CUBE =>                 "sampler_Cube",
	GL_SAMPLER_CUBE_SHADOW =>          "sampler_Cube_Shadow",
	GL_SAMPLER_1D_SHADOW =>            "sampler1D_Shadow",
	GL_SAMPLER_2D_SHADOW =>            "sampler2D_Shadow",
	GL_SAMPLER_1D_ARRAY =>             "sampler1D_Array",
	GL_SAMPLER_2D_ARRAY =>             "sampler2D_Array",
	GL_SAMPLER_1D_ARRAY_SHADOW =>      "sampler1D_Array_Shadow",
	GL_SAMPLER_2D_ARRAY_SHADOW =>      "sampler2D_Array_Shadow",
	GL_SAMPLER_2D_MULTISAMPLE =>       "sampler2D_Multisample",
	GL_SAMPLER_2D_MULTISAMPLE_ARRAY => "sampler2D_Multisample_Array",
	GL_SAMPLER_BUFFER =>               "sampler_Buffer",
	GL_SAMPLER_2D_RECT =>              "sampler2D_Rect",
	GL_SAMPLER_2D_RECT_SHADOW =>       "sampler2D_Rect_Shadow",

	# Sampler Int
	GL_INT_SAMPLER_1D =>                   "isampler1D",
	GL_INT_SAMPLER_2D =>                   "isampler2D",
	GL_INT_SAMPLER_3D =>                   "isampler3D",
	GL_INT_SAMPLER_CUBE =>                 "isampler_Cube",
	GL_INT_SAMPLER_1D_ARRAY =>             "isampler1D_Array",
	GL_INT_SAMPLER_2D_ARRAY =>             "isampler2D_Array",
	GL_INT_SAMPLER_2D_MULTISAMPLE =>       "isampler2D_Multisample",
	GL_INT_SAMPLER_2D_MULTISAMPLE_ARRAY => "isampler2D_Multisample_Array",
	GL_INT_SAMPLER_BUFFER =>               "isampler_Buffer",
	GL_INT_SAMPLER_2D_RECT =>              "isampler2D_Rect",

	# Sampler Unsigned Int
	GL_UNSIGNED_INT_SAMPLER_1D =>                   "usampler1D",
	GL_UNSIGNED_INT_SAMPLER_2D =>                   "usampler2D",
	GL_UNSIGNED_INT_SAMPLER_3D =>                   "usampler3D",
	GL_UNSIGNED_INT_SAMPLER_CUBE =>                 "usampler_Cube",
	GL_UNSIGNED_INT_SAMPLER_1D_ARRAY =>             "usampler1D_Array",
	GL_UNSIGNED_INT_SAMPLER_2D_ARRAY =>             "usampler2D_Array",
	GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE =>       "usampler2D_Multisample",
	GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE_ARRAY => "usampler2D_Multisample_Array",
	GL_UNSIGNED_INT_SAMPLER_BUFFER =>               "usampler_Buffer",
	GL_UNSIGNED_INT_SAMPLER_2D_RECT =>              "usampler2D_Rect",
)

const BASE_TYPES = Dict{DataType, NamedTuple{(:id, :name),Tuple{GLenum,String}}}(
	Float32 => (id=GL_FLOAT, name="float"),
	Float64 => (id=GL_DOUBLE, name="double"),
	Int32 => (id=GL_INT, name="int"),
	UInt32 => (id=GL_UNSIGNED_INT, name="uint"),
	Bool => (id=GL_BOOL, name="bool"),
)

const UNIFORMS = Dict{Integer,Dict{Integer,Dict{DataType,Function}}}(
	0 => Dict(
		0 => Dict(
			UInt32 => glUniform1ui,
			UInt64 => glUniform1ui,
			Int32 => glUniform1i,
			Int64 => glUniform1i,
			Float32 => glUniform1f,
			Float64 => glUniform1d,
		),
	),
	1 => Dict(
		1 => Dict(
			UInt32 => glUniform1uiv,
			UInt64 => glUniform1uiv,
			Int32 => glUniform1iv,
			Int64 => glUniform1iv,
			Float32 => glUniform1fv,
			Float64 => glUniform1dv,
		),
		2 => Dict(
			UInt32 => glUniform2uiv,
			UInt64 => glUniform2uiv,
			Int32 => glUniform2iv,
			Int64 => glUniform2iv,
			Float32 => glUniform2fv,
			Float64 => glUniform2dv,
		),
		3 => Dict(
			UInt32 => glUniform3uiv,
			UInt64 => glUniform3uiv,
			Int32 => glUniform3iv,
			Int64 => glUniform3iv,
			Float32 => glUniform3fv,
			Float64 => glUniform3dv,
		),
		4 => Dict(
			UInt32 => glUniform4uiv,
			UInt64 => glUniform4uiv,
			Int32 => glUniform4iv,
			Int64 => glUniform4iv,
			Float32 => glUniform4fv,
			Float64 => glUniform4dv,
		),
	),
	2 => Dict(
		4 => Dict(
			Float32 => glUniformMatrix2fv,
			Float64 => glUniformMatrix2dv,
		),
		9 => Dict(
			Float32 => glUniformMatrix3fv,
			Float64 => glUniformMatrix3dv,
		),
		16 => Dict(
			Float32 => glUniformMatrix4fv,
			Float64 => glUniformMatrix4dv,
		),
	),
)

end #GLLists
