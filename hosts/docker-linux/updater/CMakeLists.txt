include(YunibaseRecipe)
include(YunibaseBuildManager)
include(YunibaseUpdateManager) # Depends on Recipe/Build
include(YunibaseSourceManager) # Depends on UpdateMgr

set(root ../../..) # FIXME: Needs to be relative path

init_sources()
init_config_directory()
init_git_repositories() # Begin list-of repositories
include(${root}/sources-current.cmake)
 
register_source(YUNI CURRENT ${root}/yuni GIT origin/master)
register_source(IMPL-STABLE CURRENT ${root}/impl-stable GIT origin/master)

register_update_all()
