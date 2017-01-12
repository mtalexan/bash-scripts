#!/bin/bash

# This only works on Ubuntu or systems that that provide the tools
# update-alternatives and update-java-alternatives
#
# It should be sourced to set the java versions in the sourcing environment.
#
# $1 The version of java to use.  This must be one of the versions listed in
# update-java-alternatives --list (in the first column).

#the following are tools provided by a java package that are listed in update-alternatives
my_JAVA_TOOL_NAMES="ControlPanel extcheck idlj itweb-settings jar jarsigner java java_vm javac javadoc javah javap javaws jconsole jcontrol jdb jexec jhat jinfo jmap jps jrunscript jsadebugd jstack jstat jstatd keytool orbd pack200 policytool rmic rmid rmiregistry schemagen serialver servertool tnameserv unpack200 wsgen wsimport xjc"

if [ -z "$SELECTED_JAVA_VERSION" ] ; then
    echo "Missing java version argument, not mapping environment to new java version"
    exit 1
fi

#look for an exact match on the argument as the first whitespace separated
#column of the update-java-alternatives --list command
if [[ -z $(update-java-alternatives --list | grep "^$SELECTED_JAVA_VERSION ") ]] ; then
    echo "Java version \"$SELECTED_JAVA_VERSION\" doesn't exactly match an installed java version"
    exit 1
fi

echo "Setting java version: $SELECTED_JAVA_VERSION"

#Take the third column of the java alternatives row that matches the argument
#specified.  This should be a path to where that's installed
export JAVA_TOOL_PATH_ROOT=$(update-java-alternatives --list | grep "^$SELECTED_JAVA_VERSION " | awk '{print $3}')

#Set this so it gets used properly.  Always have it try a jre path first, then fall back to the non-jre path
export JAVA_HOME=${JAVA_TOOL_PATH_ROOT}/jre:${JAVA_TOOL_PATH_ROOT}
export PATH=${JAVA_TOOL_PATH_ROOT}/jre/bin:${JAVA_TOOL_PATH_ROOT}/bin:${PATH}

#create environment variables who's names are the same as the commands so they're forcibly mapped
#to versions in specific directories
for tool in $my_JAVA_TOOL_NAMES ; do
    tool_path=$(update-alternatives --list $tool | grep $JAVA_TOOL_PATH_ROOT)
    if [ -z "$tool_path" ] ; then
        echo "Java Tool '$tool' is not provided by installed $SELECTED_JAVA_VERSION"
    else
        export $tool="$tool_path"
    fi
done

#Run commands passed on the command line
$@
