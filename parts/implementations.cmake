# Build 
#
# INPUT:
#   YUNIBASE_ROOT_CURRENT : Path to current base
#   YUNIBASE_ROOT_STABLE : Path to stable base
#   YUNIBASE_BUILD_STABLE_PREFIX : Install path (stable)
#   YUNIBASE_BUILD_CURRENT_PREFIX : Install path (current)
#   YUNIBASE_PREBUILT_STABLE : Assume we already have stable impl. (Path)

if(APPLE)
    set(ld_library_path DYLD_LIBRARY_PATH)
else()
    set(ld_library_path LD_LIBRARY_PATH)
endif()

function(depends_current_stable current stable)
    if(NOT YUNIBASE_PREBUILT_STABLE)
        add_dependencies(${current} ${stable})
    endif()
endfunction()

# Guile (current)
if(${CMAKE_SYSTEM_NAME} STREQUAL "FreeBSD")
    set(ENVP_GUILE_BOOTSTRAP 
        M4 gm4
        CPPFLAGS -I/usr/local/include
        LDFLAGS -L/usr/local/lib
        BDW_GC_LIBS -lgc-threaded)
elseif(APPLE)
    set(ENVP_GUILE_BOOTSTRAP 
        CPPFLAGS -I/opt/pkg/include
        LDFLAGS -L/opt/pkg/lib)
else()
    set(ENVP_GUILE_BOOTSTRAP "")
endif()

set(guile_current_src ${YUNIBASE_ROOT_CURRENT}/guile)
set(guile_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/guile)
build_recipe(guile_current ${guile_current_src} ${guile_current_dest}
    GUILE "${ENVP_GUILE_BOOTSTRAP}" ${RECIPE_GUILE})
register_recipe(GUILE CURRENT guile_current)

# Sagittarius (stable + current)
set(sagittarius_stable_src ${YUNIBASE_ROOT_STABLE}/sagittarius)
set(sagittarius_current_src ${YUNIBASE_ROOT_CURRENT}/sagittarius)
set(sagittarius_stable_dest
    ${YUNIBASE_BUILD_STABLE_PREFIX}/sagittarius)
set(sagittarius_current_dest
    ${YUNIBASE_BUILD_CURRENT_PREFIX}/sagittarius)
build_recipe(sagittarius_stable ${sagittarius_stable_src}
    ${sagittarius_stable_dest}
    SAGITTARIUS "" ${RECIPE_SAGITTARIUS})
set(ENVP_SAGITTARIUS_BOOTSTRAP
    PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/sagittarius/bin
    ${ld_library_path} ${YUNIBASE_BUILD_STABLE_PREFIX}/sagittarius/lib)
build_recipe(sagittarius_current ${sagittarius_current_src}
    ${sagittarius_current_dest}
    SAGITTARIUS "${ENVP_SAGITTARIUS_BOOTSTRAP}" ${BOOTSTRAP_SAGITTARIUS})
depends_current_stable(sagittarius_current sagittarius_stable)
register_recipe(SAGITTARIUS STABLE sagittarius_stable)
register_recipe(SAGITTARIUS CURRENT sagittarius_current)

# Gauche (stable + current)
set(gauche_current_src ${YUNIBASE_ROOT_CURRENT}/gauche)
set(gauche_stable_src ${YUNIBASE_ROOT_STABLE}/gauche)
set(gauche_stable_dest ${YUNIBASE_BUILD_STABLE_PREFIX}/gauche)
build_recipe(gauche_stable ${gauche_stable_src}  ${gauche_stable_dest}
    GAUCHE "" ${RECIPE_GAUCHE})

set(ENVP_GAUCHE # Use stable on build-current
    PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/gauche/bin
    ${ld_library_path} ${YUNIBASE_BUILD_STABLE_PREFIX}/gauche/lib)
set(gauche_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/gauche)
build_recipe(gauche_current ${gauche_current_src} ${gauche_current_dest}
    GAUCHE "${ENVP_GAUCHE}" ${BOOTSTRAP_GAUCHE})
depends_current_stable(gauche_current gauche_stable)

register_recipe(GAUCHE STABLE gauche_stable)
register_recipe(GAUCHE CURRENT gauche_current)

## Gauche workaround (stable)
set(gauche_war_touch_files)
if(EXISTS ${gauche_stable_src}/.gitignore)
    file(STRINGS ${gauche_stable_src}/.gitignore gauche_gitignore)
    foreach(e ${gauche_gitignore})
        if(EXISTS "${gauche_stable_src}/${e}")
            list(APPEND gauche_war_touch_files ${e})
        endif()
    endforeach()
    workaround_touch_prebuilt_files(
        ${gauche_stable_src}
        ${gauche_war_touch_files})

    # doc/srfis.texi
    while(true)
        if(${gauche_stable_src}/doc/srfis.texi
                IS_NEWER_THAN
                ${gauche_stable_src}/src/srfis.scm)
            break()
        endif()
        message(STATUS "Touch Again(srfis.texi).")
        workaround_touch_prebuilt_files(
            ${gauche_stable_src}
            doc/srfis.texi)
    endwhile()
endif()

# NMosh (stable)
if(${CMAKE_SYSTEM_NAME} STREQUAL "FreeBSD")
    set(ENVP_NMOSH_CONFIG
        CPPFLAGS -I/usr/local/include
        LDFLAGS -L/usr/local/lib)
else()
    set(ENVP_NMOSH_CONFIG "")
endif()
set(nmosh_stable_src ${YUNIBASE_ROOT_STABLE}/nmosh)
set(nmosh_stable_dest ${YUNIBASE_BUILD_STABLE_PREFIX}/nmosh)
build_recipe(nmosh_stable ${nmosh_stable_src} ${nmosh_stable_dest}
    NMOSH "${ENVP_NMOSH_CONFIG}" ${RECIPE_NMOSH})

register_recipe(NMOSH STABLE nmosh_stable)
workaround_touch_prebuilt_files(
    ${nmosh_stable_src}
    Makefile.in
    aclocal.m4
    config.guess
    config.status
    Makefile.in
    ltmain.sh
    compile
    missing
    install-sh
    depcomp
    mkinstalldirs
    config.sub
    src/Instruction.h
    src/main.cpp
    src/labels.cpp
    src/cprocedures.cpp
    src/all-tests.scm
    src/Object-accessors.h
    src/OSConstants.h
    src/Reader.tab.cpp
    src/Reader.tab.hpp
    src/NumberReader.tab.cpp
    src/NumberReader.tab.hpp
    src/Scanner.cpp
    src/NumberScanner.cpp)

# Chibi scheme (current)
set(chibi-scheme_current_src ${YUNIBASE_ROOT_CURRENT}/chibi-scheme)
set(chibi-scheme_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/chibi-scheme)
set(ENVP_CHIBI_SCHEME_SETUP
    ${ld_library_path} ${YUNIBASE_BUILD_CURRENT_PREFIX}/chibi-scheme/lib)
build_recipe(chibi-scheme_current
    ${chibi-scheme_current_src}
    ${chibi-scheme_current_dest}
    CHIBI_SCHEME
    "${ENVP_CHIBI_SCHEME_SETUP}"
    ${RECIPE_CHIBI_SCHEME})

register_recipe(CHIBI_SCHEME CURRENT 
    # Depended on rapid-gambit
    chibi-scheme_current)

# Racket (current)
set(racket_current_src ${YUNIBASE_ROOT_CURRENT}/racket/racket/src)
set(racket_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/racket)
set(ENVP_RACKET_SETUP
    PATH ${YUNIBASE_BUILD_CURRENT_PREFIX}/racket/bin
    ${ld_library_path} ${YUNIBASE_BUILD_CURRENT_PREFIX}/racket/lib)
if(APPLE)
    # On macOS, we use unix-style installation here..
    build_recipe(racket_current
        ${racket_current_src}/../..
        ${racket_current_dest}
        RACKET
        ""
        ${RECIPE_RACKET_MACOS})

    register_recipe(RACKET CURRENT 
        racket_current)
else()
    build_recipe(racket_current
        ${racket_current_src}
        ${racket_current_dest}
        RACKET
        ""
        ${RECIPE_RACKET})
    build_recipe(racket_current_setup
        ${racket_current_src}
        ${racket_current_dest}
        RACKET
        "${ENVP_RACKET_SETUP}"
        ${RECIPE_RACKET_SETUP})

    register_recipe(RACKET CURRENT 
        racket_current
        racket_current_setup)
endif()

# Vicare (current)
set(vicare_current_src ${YUNIBASE_ROOT_CURRENT}/vicare)
set(vicare_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/vicare)
build_recipe(vicare_current
    ${vicare_current_src}
    ${vicare_current_dest}
    VICARE
    ""
    ${RECIPE_VICARE})

register_recipe(VICARE CURRENT vicare_current)

# Chicken (stable + current)
set(chicken_stable_src ${YUNIBASE_ROOT_STABLE}/chicken)
set(chicken_stable_dest ${YUNIBASE_BUILD_STABLE_PREFIX}/chicken)
build_recipe(chicken_stable ${chicken_stable_src} ${chicken_stable_dest}
    CHICKEN "" ${RECIPE_CHICKEN})
build_recipe(chicken_stable_test ${chicken_stable_src} ${chicken_stable_dest}
    CHICKEN "" ${RECIPE_CHICKEN_TEST})
set(ENVP_CHICKEN_SETUP
    PATH ${CHICKEN_INSTALL_PREFIX}/bin
    ${ld_library_path} ${CHICKEN_INSTALL_PREFIX}/lib)
build_recipe(chicken_stable_setup ${chicken_stable_src} ${chicken_stable_dest}
    CHICKEN "${ENVP_CHICKEN_SETUP}" ${RECIPE_CHICKEN_SETUP})

register_recipe(CHICKEN STABLE 
    chicken_stable
    #chicken_stable_setup
    #chicken_stable_test
    )

file(GLOB chicken_stable_csrcs ${chicken_stable_src}/*.c)

workaround_touch_prebuilt_files(
    /
    ${chicken_stable_csrcs})

message(STATUS "We still have to workaround again...")

workaround_touch_prebuilt_files(
    ${chicken_stable_src}
    setup-api.c)

message(STATUS "We still have to workaround again...")

workaround_touch_prebuilt_files(
    ${chicken_stable_src}
    setup-download.c)

message(STATUS "We still have to workaround again...")

workaround_touch_prebuilt_files(
    ${chicken_stable_src}
    # This file needs to be the newest
    # chicken-install.c # FIXME: It seems we need do this in the loop...
    debugger-client.c) 

while(true)
    if(${chicken_stable_src}/setup-download.c IS_NEWER_THAN 
            ${chicken_stable_src}/setup-api.c)
        break()
    endif()
    message(STATUS "Touch Again(setup-download.c).")
    workaround_touch_prebuilt_files(
        ${chicken_stable_src}
        setup-download.c)
endwhile()

while(true)
    if(${chicken_stable_src}/chicken-install.c IS_NEWER_THAN
            ${chicken_stable_src}/setup-download.c)
        break()
    endif()
    message(STATUS "Touch Again(chicken-install.c).")
    workaround_touch_prebuilt_files(
        ${chicken_stable_src}
        chicken-install.c)
endwhile()

set(chicken_current_src ${YUNIBASE_ROOT_CURRENT}/chicken)
set(chicken_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/chicken)
set(ENVP_CHICKEN_BUILD
    PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/chicken/bin
    ${ld_library_path} ${YUNIBASE_BUILD_STABLE_PREFIX}/chicken/lib)
set(ENVP_CHICKEN_SETUP
    PATH ${YUNIBASE_BUILD_CURRENT_PREFIX}/chicken/bin
    ${ld_library_path} ${YUNIBASE_BUILD_CURRENT_PREFIX}/chicken/lib)
build_recipe(chicken_current ${chicken_current_src} ${chicken_current_dest}
    CHICKEN "${ENVP_CHICKEN_BUILD}" ${RECIPE_CHICKEN})
build_recipe(chicken_current_test ${chicken_current_src} ${chicken_current_dest}
    CHICKEN "${ENVP_CHICKEN_SETUP}" ${RECIPE_CHICKEN_TEST})
depends_current_stable(chicken_current chicken_stable)
build_recipe(chicken_current_setup 
    ${chicken_current_src} 
    ${chicken_current_dest}
    CHICKEN "${ENVP_CHICKEN_SETUP}" ${RECIPE_CHICKEN_SETUP})

register_recipe(CHICKEN CURRENT 
    chicken_current
    chicken_current_setup
    chicken_current_test)

# Chicken5 (stable + current)
set(chicken5_stable_src ${YUNIBASE_ROOT_STABLE}/chicken5)
set(chicken5_stable_dest ${YUNIBASE_BUILD_STABLE_PREFIX}/chicken5)
build_recipe(chicken5_stable ${chicken5_stable_src} ${chicken5_stable_dest}
    CHICKEN5 "" ${RECIPE_CHICKEN5})
build_recipe(chicken5_stable_test ${chicken5_stable_src} ${chicken5_stable_dest}
    CHICKEN5 "" ${RECIPE_CHICKEN5_TEST})
set(ENVP_CHICKEN5_SETUP
    PATH ${CHICKEN5_INSTALL_PREFIX}/bin
    ${ld_library_path} ${CHICKEN5_INSTALL_PREFIX}/lib)
build_recipe(chicken5_stable_setup ${chicken5_stable_src} ${chicken5_stable_dest}
    CHICKEN "${ENVP_CHICKEN5_SETUP}" ${RECIPE_CHICKEN5_SETUP})

register_recipe(CHICKEN5 STABLE 
    chicken5_stable
    #chicken5_stable_setup
    #chicken5_stable_test
    )

file(GLOB chicken5_stable_csrcs ${chicken5_stable_src}/*.c)

workaround_touch_prebuilt_files(
    /
    ${chicken5_stable_csrcs})

workaround_touch_prebuilt_files(
    ${chicken5_stable_src}
    setup-api.c)

workaround_touch_prebuilt_files(
    ${chicken5_stable_src}
    setup-download.c)

workaround_touch_prebuilt_files(
    ${chicken5_stable_src}
    build-version.c)

workaround_touch_prebuilt_files(
    ${chicken5_stable_src}
    # This file needs to be the newest
    # chicken-install.c # FIXME: It seems we need do this in the loop...
    debugger-client.c) 

while(true)
    if(${chicken5_stable_src}/setup-download.c IS_NEWER_THAN 
            ${chicken5_stable_src}/setup-api.c)
        break()
    endif()
    message(STATUS "Touch Again(setup-download.c).")
    workaround_touch_prebuilt_files(
        ${chicken5_stable_src}
        setup-download.c)
endwhile()

while(true)
    if(${chicken5_stable_src}/chicken-install.c IS_NEWER_THAN
            ${chicken5_stable_src}/setup-download.c)
        break()
    endif()
    message(STATUS "Touch Again(chicken-install.c).")
    workaround_touch_prebuilt_files(
        ${chicken5_stable_src}
        chicken-install.c)
endwhile()

set(chicken5_current_src ${YUNIBASE_ROOT_CURRENT}/chicken5)
set(chicken5_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/chicken5)
set(ENVP_CHICKEN5_BUILD
    PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/chicken5/bin
    ${ld_library_path} ${YUNIBASE_BUILD_STABLE_PREFIX}/chicken5/lib)
set(ENVP_CHICKEN5_SETUP
    PATH ${YUNIBASE_BUILD_CURRENT_PREFIX}/chicken5/bin
    ${ld_library_path} ${YUNIBASE_BUILD_CURRENT_PREFIX}/chicken5/lib)
build_recipe(chicken5_current ${chicken5_current_src} ${chicken5_current_dest}
    CHICKEN5 "${ENVP_CHICKEN5_BUILD}" ${RECIPE_CHICKEN5})
build_recipe(chicken5_current_test ${chicken5_current_src} ${chicken5_current_dest}
    CHICKEN5 "${ENVP_CHICKEN5_SETUP}" ${RECIPE_CHICKEN5_TEST})
depends_current_stable(chicken5_current chicken5_stable)
build_recipe(chicken5_current_setup 
    ${chicken5_current_src} 
    ${chicken5_current_dest}
    CHICKEN "${ENVP_CHICKEN5_SETUP}" ${RECIPE_CHICKEN5_SETUP})

register_recipe(CHICKEN5 CURRENT 
    chicken5_current
    chicken5_current_setup
    chicken5_current_test)

# Kawa (current)
set(kawa_current_src ${YUNIBASE_ROOT_CURRENT}/kawa)
set(kawa_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/kawa)
build_recipe(kawa_current ${kawa_current_src} ${kawa_current_dest}
    KAWA "" ${RECIPE_KAWA})

register_recipe(KAWA CURRENT
    kawa_current)

# Larceny (current)
set(larceny_current_src ${YUNIBASE_ROOT_CURRENT}/larceny)
set(larceny_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/larceny)
build_recipe(larceny_current ${larceny_current_src} ${larceny_current_dest}
    LARCENY "" ${RECIPE_LARCENY})

register_recipe(LARCENY CURRENT
    larceny_current)

# Chez scheme (current)
set(chez_current_src ${YUNIBASE_ROOT_CURRENT}/chez)
set(chez_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/chez)
build_recipe(chez_current ${chez_current_src} ${chez_current_dest}
    CHEZ "" ${RECIPE_CHEZ})

if(EXISTS ${chez_current_src}/configure)
    # Workaround (Remove git dependency; we've done instanciate submodules already)
    workaround_file_edit(${chez_current_src}/configure
        "^git" "# git")
    # Workaround (patch configure script to build Linux32 on Linux64)
    workaround_file_edit(${chez_current_src}/configure
        "^  if uname -a \\| egrep 'amd64\\|x86_64'"
        "  if uname -m | egrep 'amd64|x86_64'")
endif()

register_recipe(CHEZ CURRENT
    chez_current)



# Gambit (stable + current)
set(gambit_stable_src ${YUNIBASE_ROOT_STABLE}/gambit)
set(gambit_stable_dest ${YUNIBASE_BUILD_STABLE_PREFIX}/gambit)
set(gambit_current_src ${YUNIBASE_ROOT_CURRENT}/gambit)
set(gambit_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/gambit)
build_recipe(gambit_stable ${gambit_stable_src} ${gambit_stable_dest}
    GAMBIT "" ${RECIPE_GAMBIT})

register_recipe(GAMBIT STABLE
    gambit_stable)

build_recipe(gambit_current ${gambit_current_src} ${gambit_current_dest}
    GAMBIT "" ${RECIPE_GAMBIT_BOOTSTRAP})

register_recipe(GAMBIT CURRENT
    gambit_current)

depends_current_stable(gambit_current gambit_stable)

# Rapid-gambit (current)
set(rapid_gambit_current_src ${YUNIBASE_ROOT_CURRENT}/rapid-gambit)
set(rapid_gambit_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/rapid-gambit)
set(ENVP_RAPID_GAMBIT_BOOTSTRAP
    PATH "${YUNIBASE_BUILD_CURRENT_PREFIX}/chibi-scheme/bin:${YUNIBASE_BUILD_STABLE_PREFIX}/gambit/bin"
    ${ld_library_path} ${YUNIBASE_BUILD_CURRENT_PREFIX}/chibi-scheme/lib)
build_recipe(rapid_gambit_current
    ${rapid_gambit_current_src}
    ${rapid_gambit_current_dest}
    RAPID_GAMBIT
    "${ENVP_RAPID_GAMBIT_BOOTSTRAP}"
    ${RECIPE_RAPID_GAMBIT})

register_recipe(RAPID_GAMBIT CURRENT 
    rapid_gambit_current)

add_dependencies(rapid_gambit_current
    chibi-scheme_current
    gambit_stable)

# Picrin
set(picrin_current_src ${YUNIBASE_ROOT_CURRENT}/picrin)
set(picrin_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/picrin)
set(YUNIFFI_PICRIN_PATH
    ${YUNIBASE_ROOT_CURRENT}/../yuni/yunistub/picrin)
set(YUNIFFI_INCLUDE_DIR
    ${YUNIBASE_ROOT_CURRENT}/../yuni/yunistub/include)
if(EXISTS ${picrin_current_src}/Makefile)
    if(${CMAKE_SYSTEM_NAME} STREQUAL Linux)
        # Glibc has libdl, Musl too
        set(picrin_libdl 1)
    else()
        # FIXME: We do project(NONE) so don't rely on this
        find_library(picrin_libdl dl)
    endif()
    if(picrin_libdl)
        set(YUNIFFI_PICRIN_LIBDL "-ldl")
    else()
        set(YUNIFFI_PICRIN_LIBDL "")
    endif()
    configure_file(
        ${YUNIFFI_PICRIN_PATH}/nitro.mk.in
        ${picrin_current_src}/contrib/99.yuni/nitro.mk @ONLY)
endif()
build_recipe(picrin_current
    ${picrin_current_src}
    ${picrin_current_dest}
    PICRIN
    ""
    ${RECIPE_PICRIN})
register_recipe(PICRIN CURRENT
    picrin_current)

# MIT/GNU Scheme
set(mit-scheme_stable_src ${YUNIBASE_ROOT_STABLE}/mit-scheme-amd64)
set(mit-scheme_stable_dest ${YUNIBASE_BUILD_STABLE_PREFIX}/mit-scheme)
set(mit-scheme_current_src ${YUNIBASE_ROOT_CURRENT}/mit-scheme)
set(mit-scheme_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/mit-scheme)
build_recipe(mit-scheme_stable
    ${mit-scheme_stable_src}/src
    ${mit-scheme_stable_dest}
    MIT_SCHEME
    ""
    ${RECIPE_MIT_SCHEME_AMD64})
register_recipe(MIT_SCHEME STABLE
    mit-scheme_stable)

set(ENVP_MIT_SCHEME_BOOTSTRAP
    PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/mit-scheme/bin
    ${ld_library_path} ${YUNIBASE_BUILD_STABLE_PREFIX}/mit-scheme/lib)

build_recipe(mit-scheme_current
    ${mit-scheme_current_src}/src
    ${mit-scheme_current_dest}
    MIT_SCHEME
    "${ENVP_MIT_SCHEME_BOOTSTRAP}"
    ${RECIPE_MIT_SCHEME_BOOTSTRAP})

register_recipe(MIT_SCHEME CURRENT
    mit-scheme_current)

depends_current_stable(mit-scheme_current mit-scheme_stable)

# s7yuni
set(s7yuni_current_src ${YUNIBASE_ROOT_CURRENT}/snd)
set(s7yuni_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/s7yuni)
build_recipe(s7yuni_current
    ${s7yuni_current_src}
    ${s7yuni_current_dest}
    S7YUNI
    ""
    ${RECIPE_S7YUNI})
register_recipe(S7YUNI CURRENT s7yuni_current)

