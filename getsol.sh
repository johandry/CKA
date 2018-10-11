#!/usr/bin/env bash 

P=
S=
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h | --help) echo "$0 [ password | --help | -h | --show ]"; exit 0
    ;;
    --show) S=1
    ;;
    --clean) rm -rf ./LFS258/; exit 0
    ;;
    *) P="-k $1"
    ;;
  esac
  shift
done

eval "$(echo 'U2FsdGVkX1/JhcrAln91EdUMOumsyYTs4Ja61xI9of1EeR4RX5STKxvohTCLLJXnP9SrQjfGXJAmWpP+ZQh8uEX6AaIUuEGQ88KNFjnQEaE=' | openssl enc -aes-256-cbc -salt -a -A -d $P)"
[[ -z $user ]] && echo "ERROR: invalid username" && exit 1
[[ -z $password ]] && echo "ERROR: invalid password" && exit 1

if [[ -n $S ]]; then
  echo "User: $user"
  echo "Password: $password"
  exit 0
fi

filename=$(curl -u $user:$password -sSL https://training.linuxfoundation.org/cm/LFS258 2>/dev/null | grep 'href="LFS258_V' | sed 's/.*href="\(LFS258_V.*bz2\)">.*/\1/' | tail -1)
pattern='^LFS258_V[0-9]{4}-[0-9]{2}-[0-9]{2}_SOLUTIONS.tar.bz2$'
[[ ! $filename =~ $pattern ]] && echo "ERROR: solutions file not found, check the latest file at: https://training.linuxfoundation.org/cm/LFS258. file found='$filename'" && exit 1

tmp=${filename%%_SOLUTIONS.tar.bz2}
version=${tmp##LFS258_}

md5sum_org=$(curl -u $user:$password -sSL https://training.linuxfoundation.org/cm/LFS258/md5sums.txt | grep $filename | cut -f1 -d' ')
curl -u $user:$password -sSL https://training.linuxfoundation.org/cm/LFS258/${filename} -O 
md5sum=$(md5 -q $filename)
[[ $md5sum != $md5sum_org ]] && echo "ERROR: md5sum for $filename does not match" && exit 1

tar -xf $filename
[[ $? -ne 0 ]] && echo "ERROR: failed to un-tar $filename" && exit 1
[[ ! -d LFS258 ]] && echo -e "ERROR: failed to download https://training.linuxfoundation.org/cm/LFS258/${filename}" && exit 1
rm -f $filename

echo "Downloaded latest solutions, version ${version}, at ./LFS258/SOLUTIONS/"

# curl -sSL https://lms.quickstart.com/custom/858487/LFS258-Labs_${version}.pdf -O 