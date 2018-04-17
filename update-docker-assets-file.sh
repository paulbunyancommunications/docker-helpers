#!/usr/bin/env bash
latest=$(git ls-remote https://github.com/paulbunyancommunications/docker-helpers.git | grep HEAD | awk '{ print $1}');

# for each of the customizable local files get them from the repo if they are not ignored and don't exist
for fileName in "get-docker-assets.sh"
do
	# if the file isn't part of the current project then get it from the repo
    if [ -z "$(git ls-files ${fileName//_/-})" ] && [ -z "$(git ls-files ${fileName//-/_})" ];
    then
        echo "Downloading ${fileName} $(if [ -n ${fileName} ]; then echo "and replacing existing"; fi).";
        curl --silent https://raw.githubusercontent.com/paulbunyancommunications/docker-helpers/${latest}/${fileName} > ${fileName};
    else
        echo "${fileName} is part of this project."
    fi;
done
chmod +x get-docker-assets.sh
