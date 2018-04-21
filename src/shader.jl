"""
load all content from shaders located in shaders folder in root dir
"""
function loadShaders()

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

global INST_VSH = (:INST_VSH,"""
$GLOBAL_CONTENT_SH
$CONTENT_INST_VSH
""")

global INST_VSH_GSH = (:INST_VSH_GSH,"""
$GLOBAL_CONTENT_SH
$CONTENT_INST_VSH_GSH
""")

global INST_GSH = (:INST_GSH,"""
$GLOBAL_CONTENT_SH
$CONTENT_INST_GSH
""")

global INST_FSH = (:INST_FSH,"""
$GLOBAL_CONTENT_SH
$CONTENT_INST_FSH
""")

global VSH = (:VSH,"""
$GLOBAL_CONTENT_SH
$CONTENT_VSH
""")

global FSH = (:FSH,"""
$GLOBAL_CONTENT_SH
$CONTENT_FSH
""")

global GSH = (:GSH,"""
$GLOBAL_CONTENT_SH
$CONTENT_GSH
""")

(INST_VSH, INST_VSH_GSH, INST_GSH, INST_FSH, VSH, FSH, GSH)
end
