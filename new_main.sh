git checkout --orphan new_main
git add -A
git commit -am "delete history,recommit"
git branch -D main
git branch -m main
git push -f origin main