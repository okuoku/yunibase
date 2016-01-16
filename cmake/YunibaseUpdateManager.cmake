# Update Mgr (GIT)

# Find GIT.
if(NOT YUNIBASE_GIT)
    find_package(Git)
    if(GIT_FOUND)
        set(YUNIBASE_GIT "${GIT_EXECUTABLE}")
    endif()
endif()

#

macro(init_git_repositories)
    add_custom_target(sync)
endmacro()

macro(register_git_repository tgt pth tag)
    set(_TMPL_GITUPDATE
        STEP "UpdateFetch" ${YUNIBASE_GIT} fetch
        STEP "UpdateForce" ${YUNIBASE_GIT} reset "--hard"
        # TAG HERE (don't add anything below)
        )
    set(_TMPL_GITCLEAN
        STEP "CleanGit" ${YUNIBASE_GIT} clean "-xfd" "."
        )
    build_recipe(gitupdate_${tgt}
        "${pth}" "BOGUS" # No install prefix..
        ___BOGUS__X_ # No prefix..
        ""
        ${_TMPL_GITUPDATE} ${tag})
    add_dependencies(sync gitupdate_${tgt})
endmacro()

macro(create_git_repository_handlers)
endmacro()

