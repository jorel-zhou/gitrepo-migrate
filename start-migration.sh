#!/bin/bash

for sourceURL in `cat repos.conf`
do
    projectName=`echo $sourceURL|awk -F "/" {'print $5'}`
    repoName=`echo $sourceURL|awk -F "/" {'print $6'}|awk -F "." {'print $1'}`
    echo $projectName "|" $repoName
    if [[ -n $projectName ]]; then
       echo $projectName"-"$repoName is being migrated......
       git clone $sourceURL
       cd $repoName
       (git branch -r | sed -n '/->/!s#^  origin/##p' && echo master) | xargs -L1 git checkout
       git remote add dxcgithub git@github.houston.entsvcs.net:vpc-propel/${repoName}.git
       curl -XDELETE -H "Authorization: token f637dcc729d22bdaa6a3519336475b912f3efc69" https://github.houston.entsvcs.net/api/v3/repos/vpc-propel/${repoName}
       curl -XPOST -H "Authorization: token f637dcc729d22bdaa6a3519336475b912f3efc69" https://github.houston.entsvcs.net/api/v3/orgs/vpc-propel/repos -d '{"name":"'${repoName}'", "description":"'${repoName}'"}' 1>/dev/null 2>&1
       git push --all dxcgithub
       git push --tags dxcgithub
       cd ..
       rm -rf $repoName
       echo "Done for $repoName"
    fi
done
