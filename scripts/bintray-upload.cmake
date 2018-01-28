#
# bintray-upload.cmake: Upload to bintray
#
# INPUTs:
#   UPLOAD_FILE:
#   UPLOAD_PKGNAME: Package name
#   UPLOAD_SECRETFILE: Path to secret("user:apikey") file

if(NOT UPLOAD_SECRETFILE)
    message(FATAL_ERROR "huh?")
endif()

file(STRINGS ${UPLOAD_SECRETFILE} secret)

if("${secret}" MATCHES "([a-z0-9]*):([a-z0-9]*)")
    set(user ${CMAKE_MATCH_1})
    set(key ${CMAKE_MATCH_2})
else()
    message(FATAL_ERROR "Malformed secret file")
endif()

set(pkgname ${UPLOAD_PKGNAME})
message(STATUS "Uploading ${pkgname}...")
file(UPLOAD
    ${UPLOAD_FILE}
    https://${user}:${key}@api.bintray.com/content/${user}/generic/${pkgname}/latest/${pkgname}.tar.gz?override=1)
message(STATUS "Done.")
message(STATUS "Publish immediately...")

# FIXME: It seems there's no way to POST to URL with CMake alone..

execute_process(
    COMMAND curl -X POST
    https://${user}:${key}@api.bintray.com/content/${user}/generic/${pkgname}/latest/publish
    RESULT_VARIABLE rr)

if(rr)
    message(FATAL_ERROR "Error on curl post ${rr}")
endif()

message("Done. ${log}")

