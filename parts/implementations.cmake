# Build 
#
# INPUT:
#   YUNIBASE_ROOT_CURRENT : Path to current base
#   YUNIBASE_ROOT_STABLE : Path to stable base
#   YUNIBASE_ROOT_RSRC : Path to yunibase repository root
#   YUNIBASE_BUILD_STABLE_PREFIX : Install path (stable)
#   YUNIBASE_BUILD_CURRENT_PREFIX : Install path (current)
#   YUNIBASE_PREBUILT_STABLE : Assume we already have stable impl. (Path)

function(apply_patch root pickup patchfile)
    if(EXISTS ${pickup})
        if(NOT EXISTS ${patchfile})
            message(FATAL_ERROR "Pathfile ${patchfile} was not found.")
        endif()
        if(NOT EXISTS ${root}/.yunibasepatched)
            # Apply patch
            execute_process(COMMAND
                patch -p1
                INPUT_FILE ${patchfile}
                WORKING_DIRECTORY ${root}
                RESULT_VARIABLE rr)
            if(rr)
                message(FATAL_ERROR "patch failed")
            endif()
            file(WRITE ${root}/.yunibasepatched "patched")
        endif()
    else()
        # Do nothing if pickup file was not existed
    endif()
endfunction()

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

# Guile (guile2)
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

# Guile (current)
if(${CMAKE_SYSTEM_NAME} STREQUAL "FreeBSD")
    set(ENVP_GUILE3_BOOTSTRAP 
        M4 gm4
        CPPFLAGS -I/usr/local/include
        LDFLAGS -L/usr/local/lib
        BDW_GC_LIBS -lgc-threaded)
elseif(APPLE)
    set(ENVP_GUILE3_BOOTSTRAP 
        CPPFLAGS -I/opt/pkg/include
        LDFLAGS -L/opt/pkg/lib)
else()
    set(ENVP_GUILE3_BOOTSTRAP "")
endif()

set(guile3_current_src ${YUNIBASE_ROOT_CURRENT}/guile3)
set(guile3_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/guile3)
build_recipe(guile3_current ${guile3_current_src} ${guile3_current_dest}
    GUILE "${ENVP_GUILE3_BOOTSTRAP}" ${RECIPE_GUILE3})
register_recipe(GUILE3 CURRENT guile3_current)

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
    GAUCHE "" ${RECIPE_GAUCHE_ALL})

set(ENVP_GAUCHE # Use stable on build-current
    # No LD_LIBRARY_PATH needed for Gauche
    PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/gauche/bin)
set(gauche_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/gauche)
build_recipe(gauche_current_bootstrap ${gauche_current_src} ${gauche_current_dest}
    GAUCHE "${ENVP_GAUCHE}" ${BOOTSTRAP_GAUCHE})
build_recipe(gauche_current_configbuild ${gauche_current_src} ${gauche_current_dest}
    GAUCHE "${ENVP_GAUCHE}" ${RECIPE_GAUCHE_CONFIGBUILD})
build_recipe(gauche_current_testinstall ${gauche_current_src} ${gauche_current_dest}
    GAUCHE "" ${RECIPE_GAUCHE_TESTINSTALL})
depends_current_stable(gauche_current_bootstrap gauche_stable)

register_recipe(GAUCHE STABLE gauche_stable)
register_recipe(GAUCHE CURRENT 
    gauche_current_bootstrap
    gauche_current_configbuild
    gauche_current_testinstall)

# Mosh (stable + current, require GAUCHE_CURRENT)
set(mosh_stable_src ${YUNIBASE_ROOT_STABLE}/mosh)
set(mosh_stable_dest ${YUNIBASE_BUILD_STABLE_PREFIX}/mosh)
set(mosh_current_src ${YUNIBASE_ROOT_CURRENT}/mosh)
set(mosh_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/mosh)
build_recipe(mosh_stable ${mosh_stable_src} ${mosh_stable_dest}
    MOSH "" ${RECIPE_MOSH_BUILD})
# FIXME: Need GC_DONT_GC to correctly bootstrap NMosh
#        https://github.com/higepon/mosh/issues/129
set(ENVP_MOSH
    GC_DONT_GC 1 # No need to use this on Cygwin/Linux actually
    PATH ${YUNIBASE_BUILD_CURRENT_PREFIX}/gauche/bin:${YUNIBASE_BUILD_STABLE_PREFIX}/mosh/bin
    ${ld_library_path} ${YUNIBASE_BUILD_CURRENT_PREFIX}/gauche/lib)
build_recipe(mosh_current_bootstrap ${mosh_current_src} ${mosh_current_dest}
    MOSH "${ENVP_MOSH}" ${BOOTSTRAP_MOSH})
build_recipe(mosh_current_build ${mosh_current_src} ${mosh_current_dest}
    MOSH "" ${RECIPE_MOSH_BUILD})
depends_current_stable(mosh_current_bootstrap mosh_stable)

register_recipe(MOSH STABLE mosh_stable)
register_recipe(MOSH CURRENT
    mosh_current_bootstrap
    mosh_current_build)

depends_current_stable(mosh_current_bootstrap
    gauche_current_testinstall)

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
set(racket_stable_src ${YUNIBASE_ROOT_STABLE}/racket/src)
set(racket_stable_dest ${YUNIBASE_BUILD_STABLE_PREFIX}/racket)
set(racket_current_src ${YUNIBASE_ROOT_CURRENT}/racket/racket/src)
set(racket_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/racket)
set(ENVP_RACKET_BUILD
    PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/racket/bin
    ${ld_library_path} ${YUNIBASE_BUILD_STABLE_PREFIX}/racket/lib)
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
    build_recipe(racket_stable
        ${racket_stable_src}
        ${racket_stable_dest}
        RACKET
        ""
        ${RECIPE_RACKET_STABLE})
    build_recipe(racket_current
        ${racket_current_src}
        ${racket_current_dest}
        RACKET
        "${ENVP_RACKET_BUILD}"
        ${RECIPE_RACKET_CURRENT})
    build_recipe(racket_current_setup
        ${racket_current_src}
        ${racket_current_dest}
        RACKET
        "${ENVP_RACKET_SETUP}"
        ${RECIPE_RACKET_SETUP})

    register_recipe(RACKET STABLE
        racket_stable)
    register_recipe(RACKET CURRENT 
        racket_current
        racket_current_setup)

    depends_current_stable(racket_current racket_stable)
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

# Picrin
set(picrin_current_src ${YUNIBASE_ROOT_CURRENT}/picrin)
set(picrin_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/picrin)
set(YUNIFFI_PICRIN_PATH
    ${YUNIBASE_ROOT_RSRC}/yuni/yunistub/picrin)
set(YUNIFFI_INCLUDE_DIR
    ${YUNIBASE_ROOT_RSRC}/yuni/yunistub/include)
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

# Cyclone
set(cyclone_current_src ${YUNIBASE_ROOT_CURRENT}/cyclone)
set(cyclone_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/cyclone)
set(cyclone_stable_src ${YUNIBASE_ROOT_STABLE}/cyclone)
set(cyclone_stable_dest ${YUNIBASE_BUILD_STABLE_PREFIX}/cyclone)
set(ENVP_CYCLONE # Use stable on build-current
    PATH ${YUNIBASE_BUILD_STABLE_PREFIX}/cyclone/bin)
build_recipe(cyclone_stable
    ${cyclone_stable_src}
    ${cyclone_stable_dest}
    CYCLONE
    ""
    ${RECIPE_CYCLONE})
build_recipe(cyclone_current
    ${cyclone_current_src}
    ${cyclone_current_dest}
    CYCLONE
    "${ENVP_CYCLONE}"
    ${RECIPE_CYCLONE})
depends_current_stable(cyclone_current cyclone_stable)
register_recipe(CYCLONE STABLE cyclone_stable)
register_recipe(CYCLONE CURRENT cyclone_current)

# SCM + SLIB (Stable only for now)
set(scm_stable_src ${YUNIBASE_ROOT_STABLE}/scmslib)
set(scm_stable_dest ${YUNIBASE_BUILD_STABLE_PREFIX}/scm)
build_recipe(scm_stable_scm
    ${scm_stable_src}/scm
    ${scm_stable_dest}
    SCM
    ""
    ${RECIPE_SCM})

build_recipe(scm_stable_slib
    ${scm_stable_src}/slib
    ${scm_stable_dest}
    SCM
    ""
    ${RECIPE_SLIB})
add_dependencies(scm_stable_scm scm_stable_slib)
register_recipe(SCM STABLE scm_stable_scm)

# STklos
set(stklos_current_src ${YUNIBASE_ROOT_CURRENT}/stklos)
set(stklos_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/stklos)
build_recipe(stklos_current
    ${stklos_current_src}
    ${stklos_current_dest}
    STKLOS
    ""
    ${RECIPE_STKLOS})
register_recipe(STKLOS CURRENT stklos_current)

# Digamma
set(digamma_current_src ${YUNIBASE_ROOT_CURRENT}/digamma)
set(digamma_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/digamma)
set(ENVP_DIGAMMA_OVERRIDE
    PATH ${YUNIBASE_ROOT_RSRC}/overrides/llvm-13)
build_recipe(digamma_current
    ${digamma_current_src}
    ${digamma_current_dest}
    DIGAMMA
    "${ENVP_DIGAMMA_OVERRIDE}"
    ${RECIPE_DIGAMMA})
register_recipe(DIGAMMA CURRENT digamma_current)

# Foment
set(foment_current_src ${YUNIBASE_ROOT_CURRENT}/foment)
set(foment_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/foment)
build_recipe(foment_current
    ${foment_current_src}
    ${foment_current_dest}
    FOMENT
    ""
    ${RECIPE_FOMENT})
register_recipe(FOMENT CURRENT foment_current)
apply_patch(${foment_current_src} ${foment_current_src}/unix/makefile
    ${YUNIBASE_ROOT_RSRC}/patches/foment/0001-Ident-as-yunibase.patch)

# Bigloo
set(bigloo_stable_src ${YUNIBASE_ROOT_STABLE}/bigloo)
set(bigloo_stable_dest ${YUNIBASE_BUILD_STABLE_PREFIX}/bigloo)
set(bigloo_current_src ${YUNIBASE_ROOT_CURRENT}/bigloo)
set(bigloo_current_dest ${YUNIBASE_BUILD_CURRENT_PREFIX}/bigloo)

build_recipe(bigloo_stable
    ${bigloo_stable_src}
    ${bigloo_stable_dest}
    BIGLOO
    ""
    ${RECIPE_BIGLOO_STABLE})

register_recipe(BIGLOO STABLE
    bigloo_stable)

set(ENVP_BIGLOO_BOOTSTRAP
    PATH ${bigloo_stable_dest}/bin)

build_recipe(bigloo_current
    ${bigloo_current_src}
    ${bigloo_current_dest}
    BIGLOO
    "${ENVP_BIGLOO_BOOTSTRAP}"
    ${RECIPE_BIGLOO_CURRENT})

register_recipe(BIGLOO CURRENT
    bigloo_current)

depends_current_stable(bigloo_current bigloo_stable)
