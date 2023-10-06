#!/bin/bash
# generage diary
getContent(){
title=$1 tag=$2 categories=$3
cat <<- _EOF_
---
title: {{ $title }}
date: {{ $todayTime }}
updated: {{ $todayTime }}
description: {{ $title }}
tags:
  - $tag
---
_EOF_
#categories:
#  - categories
return
}
title=$1 tag=$2 categories=$3
todayTime=$(date +'%Y-%m-%d %H:%M:%S')
today=$(date +'%Y%m%d%H%M')
if [ -n $1 ]; then
        getContent $title $tag $categories > "${today}.md"
else
        echo 'error:no title!'
fi
