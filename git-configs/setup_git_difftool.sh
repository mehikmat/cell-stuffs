# setup vimdiff as git diff tool which is better than default git diff tool
$ git config --global diff.tool vimdiff
# setup vimdiff as git merging tool
$ git config --global merge.tool vimdiff
# disable git prompt while launching gitdiff tool
$ git config --global difftool.prompt false
# setup git difftool alias as dt
$ git config --global alias.dt difftool
