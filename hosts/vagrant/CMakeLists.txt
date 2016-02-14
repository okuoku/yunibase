cmake_minimum_required(VERSION 3.0)
project(yunibuild-vagrant NONE)

add_custom_target(base) # Setup yunibuild boxes
add_custom_target(image) # Setup yunibase boxes
add_custom_target(yunitest) # Test with ${YUNIBASE_WITH_YUNI}
add_custom_target(destroy) # Destroy current image
add_custom_target(stop) # Stop VMs on yunitest

function(add_vagrant_sshconfig tgt nam fil)
    add_custom_target(${tgt}
        COMMAND ${CMAKE_COMMAND} 
        -DOUT=${fil}
        -DPATH=${CMAKE_CURRENT_BINARY_DIR}/${nam}
        -P ${CMAKE_CURRENT_LIST_DIR}/vagrant-fetch-sshconfig.cmake
        COMMENT "Query VM ssh config(${nam})")
endfunction()

function(add_vagrant_rsync_command tgt sshcfg tgtbase)
    add_custom_target(${tgt}
        COMMAND rsync --archive --delete -z --copy-links
        --chmod=ugo=rwX --no-perms --no-owner --no-group
        --rsync-path "sudo rsync" -e "ssh -F ${sshcfg}"
        --exclude .vagrant/ --exclude .git/
        ${ARGN} vagrant@default:${tgtbase}
        COMMENT "Rsync(${tgt})...")
endfunction()

function(add_vagrant_ssh tgt sshcfg)
    add_custom_target(${tgt}
        COMMAND ssh -F ${sshcfg} vagrant@default
        ${ARGN})
endfunction()

function(add_vagrant_provision tgt nam addnam)
    file(REMOVE ${CMAKE_CURRENT_BINARY_DIR}/${nam}/package.box)
    add_custom_target(${tgt}
        COMMAND vagrant up
        COMMAND vagrant provision # FIXME: Need this?
        COMMAND vagrant halt
        COMMAND vagrant package
        COMMAND vagrant destroy -f
        COMMAND vagrant box add --force --name ${addnam} package.box
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${nam}
        COMMENT "Provisioning(${tgt})...")
endfunction()


## FUNCTIONS
##  Assumes ${nam}/SshConfig for ssh config

function(add_vagrant_up tgt nam)
    add_vagrant_sshconfig(${tgt}_sshconfig ${nam}
        ${CMAKE_CURRENT_BINARY_DIR}/${nam}/SshConfig)
    add_custom_target(${tgt}_up
        COMMAND vagrant up
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${nam}
        COMMENT "Starting VM(${tgt})...")
    add_custom_target(${tgt})
    add_dependencies(${tgt} ${tgt}_up ${tgt}_sshconfig)
    add_dependencies(${tgt}_sshconfig ${tgt}_up)
endfunction()

function(add_vagrant_sync tgt nam tgtbase)
    add_vagrant_rsync_command(${tgt}
        ${CMAKE_CURRENT_BINARY_DIR}/${nam}/SshConfig
        ${tgtbase} ${ARGN})
endfunction()


function(add_vagrant_run tgt nam)
    add_vagrant_ssh(${tgt}
        ${CMAKE_CURRENT_BINARY_DIR}/${nam}/SshConfig
        ${ARGN})
endfunction()

function(add_vagrant_package tgt nam addnam)
    file(REMOVE ${CMAKE_CURRENT_BINARY_DIR}/${nam}/package.box)
    add_custom_target(${tgt}
        COMMAND vagrant up
        # COMMAND vagrant provision # FIXME: Need this?
        COMMAND vagrant halt
        COMMAND vagrant package
        COMMAND vagrant destroy -f
        COMMAND vagrant box add --force --name ${addnam} package.box
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${nam}
        COMMENT "Packaging(${tgt})...")
endfunction()

function(add_vagrant_stop tgt nam)
    add_custom_target(${tgt}
        COMMAND vagrant halt
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${nam}
        COMMENT "Halting(${tgt})...")
endfunction()

function(add_vagrant_destroy tgt nam)
    add_custom_target(${tgt}
        COMMAND vagrant destroy -f
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${nam}
        COMMENT "Destroy(${tgt})...")
endfunction()

# VM state directories
function(register_vagrantfile nam pth)
    file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${nam})
    configure_file(
        ${pth}
        ${CMAKE_CURRENT_BINARY_DIR}/${nam}/Vagrantfile
        COPYONLY)
endfunction()

# FBSD10
register_vagrantfile(
    fbsd10-yunibuild
    ${CMAKE_CURRENT_LIST_DIR}/fbsd10-yunibuild/Vagrantfile)
register_vagrantfile(
    fbsd10-yunibase
    ${CMAKE_CURRENT_LIST_DIR}/fbsd10-yunibase/Vagrantfile)

add_vagrant_provision(fbsd10-yunibuild-image 
    fbsd10-yunibuild "okuoku/yunibuild-fbsd10")

add_vagrant_up(fbsd10-yunibase-image
    fbsd10-yunibase)
add_vagrant_sync(fbsd10-yunibase-sync
    fbsd10-yunibase /home/vagrant/yunibase
    ${CMAKE_CURRENT_LIST_DIR}/../..)
add_vagrant_run(fbsd10-yunibase-build
    fbsd10-yunibase
    sudo cmake -DINPLACE=TRUE
    -DALTPREFIX=/usr/local
    -DUSE_GMAKE=TRUE
    "-DONLY=CHIBI_SCHEME@NMOSH@RACKET"
    -P /home/vagrant/yunibase/scripts/build-on-root.cmake)
add_vagrant_stop(fbsd10-yunibase-build-stop
    fbsd10-yunibase)
add_vagrant_destroy(fbsd10-yunibase-destroy
    fbsd10-yunibase)
add_vagrant_package(fbsd10-yunibase-package
    fbsd10-yunibase
    "okuoku/yunibase-fbsd10")

add_dependencies(fbsd10-yunibase-sync fbsd10-yunibase-image)
add_dependencies(fbsd10-yunibase-build fbsd10-yunibase-sync)
add_dependencies(fbsd10-yunibase-build-stop fbsd10-yunibase-build)
add_dependencies(fbsd10-yunibase-package fbsd10-yunibase-build)

add_dependencies(base fbsd10-yunibuild-image)
add_dependencies(image fbsd10-yunibase-build-stop)


# FBSD11
register_vagrantfile(
    fbsd11-yunibuild
    ${CMAKE_CURRENT_LIST_DIR}/fbsd11-yunibuild/Vagrantfile)
register_vagrantfile(
    fbsd11-yunibase
    ${CMAKE_CURRENT_LIST_DIR}/fbsd11-yunibase/Vagrantfile)

add_vagrant_provision(fbsd11-yunibuild-image 
    fbsd11-yunibuild "okuoku/yunibuild-fbsd11")

add_vagrant_up(fbsd11-yunibase-image
    fbsd11-yunibase)
add_vagrant_sync(fbsd11-yunibase-sync
    fbsd11-yunibase /home/vagrant/yunibase
    ${CMAKE_CURRENT_LIST_DIR}/../..)
add_vagrant_run(fbsd11-yunibase-build
    fbsd11-yunibase
    sudo cmake -DINPLACE=TRUE
    -DALTPREFIX=/usr/local
    -DUSE_GMAKE=TRUE
    "-DONLY=CHIBI_SCHEME@NMOSH@RACKET"
    -P /home/vagrant/yunibase/scripts/build-on-root.cmake)
add_vagrant_stop(fbsd11-yunibase-build-stop
    fbsd11-yunibase)
add_vagrant_destroy(fbsd11-yunibase-destroy
    fbsd11-yunibase)
add_vagrant_package(fbsd11-yunibase-package
    fbsd11-yunibase
    "okuoku/yunibase-fbsd11")

add_dependencies(fbsd11-yunibase-sync fbsd11-yunibase-image)
add_dependencies(fbsd11-yunibase-build fbsd11-yunibase-sync)
add_dependencies(fbsd11-yunibase-build-stop fbsd11-yunibase-build)
add_dependencies(fbsd11-yunibase-package fbsd11-yunibase-build)

add_dependencies(base fbsd11-yunibuild-image)
add_dependencies(image fbsd11-yunibase-build-stop)

# Destroy
add_dependencies(destroy fbsd11-yunibase-destroy fbsd10-yunibase-destroy)

# Yunitest
#  Currently, we use -build target for testing.

function(add_yunitest tgt nam)
    add_vagrant_up(${tgt}_up ${nam})
    add_vagrant_sync(${tgt}_sync ${nam}
        /yunitest ${YUNIBASE_WITH_YUNI})
    add_vagrant_run(${tgt}_run ${nam}
        sudo cmake -P 
        /yunitest/yuni/integration/buildhost-yunibase/test-on-root.cmake)
    add_vagrant_stop(${tgt}_stop ${nam})
    add_vagrant_stop(${tgt}_post ${nam})
    add_custom_target(${tgt})
    add_dependencies(${tgt} ${tgt}_post)
    add_dependencies(${tgt}_post ${tgt}_run)
    add_dependencies(${tgt}_run ${tgt}_sync)
    add_dependencies(${tgt}_sync ${tgt}_up)
    add_dependencies(yunitest ${tgt})
    add_dependencies(stop ${tgt}_stop)
endfunction()

if(YUNIBASE_WITH_YUNI)
    add_yunitest(fbsd10-yunitest fbsd10-yunibase)
    add_yunitest(fbsd11-yunitest fbsd11-yunibase)
endif()
