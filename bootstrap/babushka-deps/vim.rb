require 'etc'

dep "vim", :user do
  requires 'vim.managed'
  requires 'vundle'.with(:user => user)
  requires 'vimrc'.with(:user => user)
end

dep "vim.managed" do
  provides "vim"
end

dep "vundle", :user do
  user_home = Etc.getpwnam(user).dir
  vundle_dir = File.join(user_home, ".vim", "bundle", "vundle")
  
  met? { vundle_dir.p.dir? }
  meet {
    shell! "git clone https://github.com/gmarik/vundle.git #{vundle_dir}"
    shell! "chown -R #{user}:#{user} #{File.join(user_home, ".vim")}"
  }
end

dep "vimrc", :user do
  user_home = Etc.getpwnam(user).dir
  vimrc = File.join(user_home, ".vimrc")
  vimrc_content = <<-EOS

set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'https://github.com/sjbach/lusty.git'
Bundle 'https://github.com/majutsushi/tagbar.git'
Bundle 'https://github.com/altercation/vim-colors-solarized.git'
Bundle 'https://github.com/ervandew/supertab.git'

filetype plugin indent on

BundleInstall

let g:SuperTabDefaultCompletionType = "context"

set background=dark
let g:solarized_termtrans=1
let g:solarized_termcolors=256
let g:solarized_contrast="high"
let g:solarized_visibility="high"
colorscheme solarized

set nobackup
set noswapfile
set mouse=a
set hidden

let g:tagbar_usearrows = 1

EOS

  met? { vimrc.p.file? && vimrc.p.read == vimrc_content }
  meet { vimrc.p.open("w+") {|f| f << vimrc_content } }
end

