"""
load all content from shaders located in shaders folder in root dir
"""
function loadShaders()
  CONTENT_SH = fileGetContents("shaders/global.glsl")
  CONTENT_INST_VSH = fileGetContents("shaders/inst_vsh.glsl")
  CONTENT_INST_VSH_GSH = fileGetContents("shaders/inst_vsh_gsh.glsl")
  CONTENT_INST_CSH_VSH_GSH = fileGetContents("shaders/inst_csh_vsh_gsh.glsl")
  CONTENT_INST_GSH = fileGetContents("shaders/inst_gsh.glsl")
  CONTENT_INST_FSH = fileGetContents("shaders/inst_fsh.glsl")
  CONTENT_VSH_TEXTURE = fileGetContents("shaders/vsh_texture.glsl")
  CONTENT_VSH = fileGetContents("shaders/vsh.glsl")
  CONTENT_FSH = fileGetContents("shaders/fsh.glsl")
  CONTENT_GSH = fileGetContents("shaders/gsh.glsl")
  CONTENT_CSH = fileGetContents("shaders/csh.glsl")
  CONTENT_CHUNKS_CSH = fileGetContents("shaders/chunks_csh.glsl")
  CONTENT_INST_CSH = fileGetContents("shaders/inst_csh.glsl")
  CONTENT_SCREEN_VSH = fileGetContents("shaders/screen_vsh.glsl")
  CONTENT_SCREEN_FSH = fileGetContents("shaders/screen_fsh.glsl")
  CONTENT_BG_FSH = fileGetContents("shaders/bg_fsh.glsl")
  
  GLOBAL_CONTENT_SH = """
  $(get_glsl_version_string())
  $CONTENT_SH
  """

  #--------------------------------------

  global INST_VSH = (:INST_VSH, :VSH, """
  $GLOBAL_CONTENT_SH
  $CONTENT_INST_VSH
  """)

  global INST_VSH_GSH = (:INST_VSH_GSH, :VSH, """
  $GLOBAL_CONTENT_SH
  $CONTENT_INST_VSH_GSH
  """)
  
  global INST_CSH_VSH_GSH = (:INST_CSH_VSH_GSH, :VSH, """
  $GLOBAL_CONTENT_SH
  $CONTENT_INST_CSH_VSH_GSH
  """)

  global INST_GSH = (:INST_GSH, :GSH, """
  $GLOBAL_CONTENT_SH
  $CONTENT_INST_GSH
  """)

  global INST_FSH = (:INST_FSH, :FSH, """
  $GLOBAL_CONTENT_SH
  $CONTENT_INST_FSH
  """)

  global VSH_TEXTURE = (:VSH_TEXTURE, :VSH, """
  $GLOBAL_CONTENT_SH
  $CONTENT_VSH_TEXTURE
  """)

  global VSH = (:VSH, :VSH, """
  $GLOBAL_CONTENT_SH
  $CONTENT_VSH
  """)

  global FSH = (:FSH, :FSH, """
  $GLOBAL_CONTENT_SH
  $CONTENT_FSH
  """)

  global GSH = (:GSH, :GSH, """
  $GLOBAL_CONTENT_SH
  $CONTENT_GSH
  """)
  
  global CSH = (:CSH, :CSH, """
  $GLOBAL_CONTENT_SH
  $CONTENT_CSH
  """)
  
  global CHUNKS_CSH = (:CHUNKS_CSH, :CSH, """
  $GLOBAL_CONTENT_SH
  $CONTENT_CHUNKS_CSH
  """)
  
  global INST_CSH = (:INST_CSH, :CSH, """
  $GLOBAL_CONTENT_SH
  $CONTENT_INST_CSH
  """)
  
  global SCREEN_VSH = (:PLANE_VSH, :VSH, """
  $(get_glsl_version_string())
  $CONTENT_SCREEN_VSH
  """)

  global SCREEN_FSH = (:PLANE_FSH, :FSH, """
  $(get_glsl_version_string())
  $CONTENT_SCREEN_FSH
  """)
  
  global BG_FSH = (:BG_FSH, :FSH, """
  $GLOBAL_CONTENT_SH
  $CONTENT_BG_FSH
  """)

  (INST_VSH, INST_VSH_GSH, INST_GSH, INST_FSH, VSH_TEXTURE, VSH, FSH, GSH, CSH, SCREEN_VSH, SCREEN_FSH, INST_CSH, CHUNKS_CSH, INST_CSH_VSH_GSH, BG_FSH)
end
