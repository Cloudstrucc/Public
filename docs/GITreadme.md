# 1. First, remove the file from git tracking while keeping it locally

```powershell
git rm --cached "polymorphiclookupconfig-real copy.json"
```

# 2. Reset the last commit (but keep the changes in working directory)

```powershell
git reset --soft HEAD~1
```

# 3. Update .gitignore to prevent future commits of this file

```powershell
echo "polymorphiclookupconfig-real copy.json" >> .gitignore
```

# 4. Add the updated .gitignore and any other changes you want to keep

```powershell
git add .gitignore
git add .
```

# 5. Create a new commit without the sensitive file

```powershell
git commit -m "polylookup upsert with solution feature fix - removed sensitive file"
```

# 6. Push the changes

```powershell
git push origin main
```
