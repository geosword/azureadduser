#!/usr/bin/env bash
# check for parameters
function usage {
    echo "Dependencies: openssl, jq, az (configured to work with the matillion account)"
    echo "Usage: $0 <User's name> <group>"
    echo "Example:"
    echo "$0 'John Smith' mtln-sa"
}
if [ $# -lt 2 ]; then
  usage
  exit 1
fi

if [ $(echo $1 | wc -w) != "2" ]; then
  usage
  echo ""
  echo "The first parameter needs to be two names"
  exit 1
fi
DRYRUN=0
RANDOMPASSWORDLEN=10
OPENSSL=$(which openssl)
JQ=$(which jq)
AWK=$(which awk)
AZ=$(which az)
PASSWORD=$($OPENSSL rand -base64 $RANDOMPASSWORDLEN)
# generate the username name
USERNAME=$(echo "${1/ /.}" | $AWK '{print tolower($0)}')
USERNAME="${USERNAME}@matillion.com"
USERJSON=$($AZ ad user create --user-principal-name ${USERNAME} --display-name '$1' --password '$PASSWORD' --force-change-password-next-login true) &&
OBJECTID=$(echo $USERJSON | $JQ -r ".objectId") &&
$AZ ad group member add --group '$2' --member-id $OBJECTID
if [ $? -eq 0 ]; then
  echo "Looks like everything worked. The details are as follows:"
  echo "Username: $USERNAME"
  echo "Password: $PASSWORD"
  echo "Communicate these details SECURELY to the user, they will be asked to change thier password once they login"
fi
