#
# update-tagfile.cmake
#
# INPUTs:
#   TAGPROTOCOL: GIT | STATIC
#   TAG: commit hash(GIT) or string(STATIC)
#   TAGPATH: Path to tag source(GIT)
#   DEST: Full path to destination file(update target)

file(WRITE ${DEST} "oh.")

