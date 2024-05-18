#!/bin/bash

. ${tools_dir}/vm_getuimode.rc
xconf_dir=${DirBakConf}/uimode_${uimode}

cp -Rf ${xconf_dir}/.  ~/
