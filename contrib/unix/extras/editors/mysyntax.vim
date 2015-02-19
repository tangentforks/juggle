augroup syntax
au! BufNewFile,BufReadPost *.ijs
au  BufNewFile,BufReadPost *.ijs  so $JLIB/contrib/unix/extras/editors/ijs.vim
augroup END
