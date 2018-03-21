#
# YunibaseArtifactUpload: Archive and Upload artifact
#
# INPUTs:
#   YUNIBASE_ROOT: Root for yunibase (uses {root}/scripts)
#   YUNIBASE_BUILD_CURRENT_PREFIX: Prefix for artifact
#   YUNIBASE_BINTRAY_USERNAME: Username for bintray
#   YUNIBASE_BINTRAY_APIKEY: Api key for bintray
# 

function(yunibase_artifact_archive tgt impl branch outpath)
    add_custom_target(${tgt}
        ${CMAKE_COMMAND} -E tar "cvzf" ${outpath} ${impl}
        WORKING_DIRECTORY ${YUNIBASE_BUILD_${branch}_PREFIX})
endfunction()

function(yunibase_artifact_gen_secretfile fil)
    if(NOT YUNIBASE_BINTRAY_USERNAME)
        message(FATAL_ERROR "YUNIBASE_BINTRAY_USERNAME is not set")
    endif()

    if(NOT YUNIBASE_BINTRAY_APIKEY)
        message(FATAL_ERROR "YUNIBASE_BINTRAY_APIKEY is not set")
    endif()

    file(WRITE 
        ${fil}
        "${YUNIBASE_BINTRAY_USERNAME}:${YUNIBASE_BINTRAY_APIKEY}")
endfunction()

function(yunibase_artifact_upload tgt pkgname fil secretfile)
    add_custom_target(${tgt}
        ${CMAKE_COMMAND} 
        -DUPLOAD_FILE=${fil}
        -DUPLOAD_PKGNAME=${pkgname}
        -DUPLOAD_SECRETFILE=${secretfile}
        -P ${YUNIBASE_ROOT}/scripts/bintray-upload.cmake)
endfunction()


