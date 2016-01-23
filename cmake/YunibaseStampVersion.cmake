function(add_yunibase_stamp_version tgt root fil)
    add_custom_target(${tgt}
        COMMAND ${CMAKE_COMMAND}
        "-DROOT=${root}"
        "-DOUTPUT=${fil}"
        -P ${root}/cmake/YunibaseStampVersionGen.cmake
        COMMENT "Generating version stamp")
endfunction()
