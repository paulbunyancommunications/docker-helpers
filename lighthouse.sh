#!/bin/sh
set -e
. ./.env

# Usage: sh lighthouse.sh --OUTPUT="lighthouse" --URL="https://example.com"

CHROME_FLAGS="--new-window --headless --no-sandbox --ignore-certificate-errors --disable-gpu"
CHROME_DESKTOP_FLAG="--window-size=1920,1080"
CHROME_MOBILE_FLAG="--window-size=320,568"
OUTPUT="lighthouse-${APP_NAME}"
URL="https://web"
OUTPUT_PATH="${PWD}/tests/_output"

# get parameters
for i in "$@"
do
case $i in
    -c=*|--CHROME_FLAGS=*)
    CHROME_FLAGS="${i#*=}"
    shift # past argument=value
    ;;
    -n=*|--OUTPUT=*)
    OUTPUT="${i#*=}"
    shift # past argument=value
    ;;
    -u=*|--URL=*)
    URL="${i#*=}"
    shift # past argument=value
    ;;
    *)
          # unknown option
    ;;
esac
done

# Slugify the output file prefix
OUTPUT=$(echo "$OUTPUT" | iconv -t ascii//TRANSLIT | sed -r s/[^a-zA-Z0-9]+/-/g | sed -r s/^-+\|-+$//g | tr A-Z a-z)

# echo CHROME_FLAGS $CHROME_FLAGS
# echo OUTPUT_NAME $OUTPUT_NAME
# echo OUTPUT_PATH $OUTPUT_PATH
# echo URL $URL
#
# exit 0

# make sure the output path exists
if [ -d $OUTPUT_PATH ]; then mkdir -p ${OUTPUT_PATH}; fi;

# Install assets needed for Lighthouse to function. Run this inside the code container
apt-get -qq -y update
apt-get -qq -y install gconf-service libasound2 libatk1.0-0 libcairo2 libcups2 libfontconfig1 libgdk-pixbuf2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libxss1 fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget
# https://stackoverflow.com/a/47204160
if [ ! -f google-chrome-stable_current_amd64.deb ]; then wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; fi;
dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy install
echo "Google version: $(google-chrome-stable --version)"
yarn global add lighthouse
echo "Lighthouse version: $(lighthouse --version)"
# then run:
# lighthouse --chrome-flags="--headless --no-sandbox --ignore-certificate-errors --disable-gpu" --output json --output html --output-path ./tests/_output/lighthouse/report.json https://github.com
# lighthouse --chrome-flags="--headless --no-sandbox --ignore-certificate-errors --disable-gpu" --view https://github.com

echo "Running desktop check..."
lighthouse --quiet --disable-device-emulation --chrome-flags="${CHROME_FLAGS} ${CHROME_DESKTOP_FLAG}" --output=json --output=html --output-path="${OUTPUT_PATH}/${OUTPUT}-desktop" $URL

echo "Running mobile check..."
lighthouse --quiet --disable-device-emulation --chrome-flags="${CHROME_FLAGS} ${CHROME_MOBILE_FLAG}" --output=json --output=html --output-path="${OUTPUT_PATH}/${OUTPUT}-mobile" $URL
