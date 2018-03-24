CONTENT_SH = fileGetContents("shaders/global.glsl")
CONTENT_INST_VSH = fileGetContents("shaders/inst_vsh.glsl")
CONTENT_INST_VSH_GSH = fileGetContents("shaders/inst_vsh_gsh.glsl")
CONTENT_INST_GSH = fileGetContents("shaders/inst_gsh.glsl")
CONTENT_INST_FSH = fileGetContents("shaders/inst_fsh.glsl")
CONTENT_VSH = fileGetContents("shaders/vsh.glsl")
CONTENT_FSH = fileGetContents("shaders/fsh.glsl")
CONTENT_GSH = fileGetContents("shaders/gsh.glsl")

GLOBAL_CONTENT_SH = """
$(get_glsl_version_string())
$CONTENT_SH
"""

#--------------------------------------

INST_VSH = (:INST_VSH,"""
$GLOBAL_CONTENT_SH
$CONTENT_INST_VSH
""")

INST_VSH_GSH = (:INST_VSH_GSH,"""
$GLOBAL_CONTENT_SH
$CONTENT_INST_VSH_GSH
""")

INST_GSH = (:INST_GSH,"""
$GLOBAL_CONTENT_SH
$CONTENT_INST_GSH
""")

INST_FSH = (:INST_FSH,"""
$GLOBAL_CONTENT_SH
$CONTENT_INST_FSH
""")

VSH = (:VSH,"""
$GLOBAL_CONTENT_SH
$CONTENT_VSH
""")

FSH = (:FSH,"""
$GLOBAL_CONTENT_SH
$CONTENT_FSH
""")

GSH = (:GSH,"""
$GLOBAL_CONTENT_SH
$CONTENT_GSH
""")