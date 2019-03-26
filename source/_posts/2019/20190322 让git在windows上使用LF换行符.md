----
title: 让git在windows上使用LF换行符
categories:
- 备忘
- 技术
tags:
- {{basic_tags_1}}
- {{basic_tags_2}}
----

= 让git在windows上使用LF换行符
:stem: latexmath
:icons: font

```bash
 git config --global core.eol lf
 git config --global core.autocrlf input
```

For repos that were checked out after those global settings were set, everything will be checked out as whatever it is in the repo – hopefully LF (\n). Any CRLF will be converted to just LF on checkin.

With an existing repo that you have already checked out – that has the correct line endings in the repo but not your working copy – you can run the following commands to fix it:

```bash
git rm -rf --cached .
git reset --hard HEAD
```

This will delete (rm) recursively (r) without prompt (-f), all files except those that you have edited (--cached), from the current directory (.). The reset then returns all of those files to a state where they have their true line endings (matching what's in the repo).

If you need to fix the line endings of files in a repo, I recommend grabbing an editor that will let you do that in bulk like IntelliJ or Sublime Text, but I'm sure any good one will likely support this.




