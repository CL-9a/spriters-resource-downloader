#!/bin/bash
reg="resource.com/([a-zA-Z0-9_-]+)/([a-zA-Z0-9_-]+)"

echo regex on link

if [[ "$1" =~ $reg ]]; then
	platform=${BASH_REMATCH[1]}
	game=${BASH_REMATCH[2]}
else
	echo "couldn't find platform or game"
	exit 1
fi

echo downloading resource page
data="$(curl --silent --fail $1)"
res=$?
echo done

echo "checking data"
if test "$res" != "0"; then
	echo "curl exit status: $res"
	echo "data fetched: $data"
	exit 1
fi

if [ -z "$data" ]; then
	echo "no data"
	exit
fi
echo "done"

echo "finding links"
links="$(echo $data | pup '[href*="/sheet/"] attr{href}')"
echo done

regres="/sheet/([0-9]+)"
mkdir --parents --verbose "${game}-${platform}"
cd "./${game}-${platform}"

echo "iterating links"
for link in $links; do
	echo "regex to get resource"
	if [[ "$link" =~ $regres ]]; then
		res=${BASH_REMATCH[1]}
		echo "downloading resource $res"

		#wget --content-disposition --directory-prefix="${game}-${platform}" "https://www.spriters-resource.com/download/${res}/"
		curl --remote-name --remote-header-name --location "https://www.spriters-resource.com/download/${res}/"
	else
		echo "couldn't find res in $link"
	fi
done
echo "done"

