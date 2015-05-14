#!/bin/bash

data_path=./data

IFS="|"
cat $data_path/rss | while read feed ; do 
  curl -s $feed | xml2 | grep /rss/channel | 2csv -d '|' item title link dc:creator pubDate| while read title link creator pubdate ; do
    easy_title=$(echo $title | md5sum | cut -b-32)
    if (! grep -q $easy_title $data_path/links) then
      title=$(echo $title | tr -d \" )
      date=$(echo $pubdate | tr -d \" )
      dato=$(date --date="$date" --rfc-3339=date)
      url="site/_posts/$dato-$easy_title.html"
      cat <<EOF > $data_path/$url
---
layout:     post
title: 	    "$title"
post_author:	    $creator
post_date:	    $date
post_site:	    $(echo $link|cut -d/ -f3) 
post_link:	    $link
---
EOF
      ( cd python-readability-master ; python -m readability.readability -u $link >> $data_path/../$url  )
      echo $easy_title >> links

  fi 
  done

done


/usr/bin/jekyll --limit_posts=200 $data_path/site $data_path/static
