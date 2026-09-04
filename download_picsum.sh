#!/bin/bash
ids=(0 1 2 3 4 5 6 7 8 9 180 370 445 48 1059)
for i in "${!ids[@]}"; do
  curl -L -s -o "frontend/web/images/blog/blog_real_$i.jpg" "https://picsum.photos/id/${ids[$i]}/400/225"
  echo "Downloaded ${ids[$i]}"
done
