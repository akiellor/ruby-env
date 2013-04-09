require 'etc'

dep "vim", :user do
  requires 'vim.bin'.with(:user => user)
  requires 'exuberant-ctags.managed'
  requires 'vundle'.with(:user => user)
  requires 'vimrc'.with(:user => user)
end

dep "vim.bin", :user do
  requires 'user.bin'.with(:user => user)
  
  user_home = Etc.getpwnam(user).dir
  vim_bin = File.join(user_home, ".opt", "vim73")
  
  met? { vim_bin.p.dir? }
  meet do
    vim_bin.p.parent.create_dir
    shell! "cd #{vim_bin.p.parent} && curl ftp://ftp.vim.org/pub/vim/unix/vim-7.3.tar.bz2 | tar jxf -"
    shell! "cd #{vim_bin} && ./configure --enable-rubyinterp"
    shell! "cd #{vim_bin} && make"
    shell! "ln -s #{File.join(vim_bin, "src", "vim")} #{File.join(user_home, ".bin", "vim")}"
    shell! "chown #{user}:#{user} -R #{user_home}"
  end
end

dep "user.bin", :user do
  requires '.profile.d'.with(:user => user)

  user_home = Etc.getpwnam(user).dir
  user_bin = File.join(user_home, ".bin")
  profile_bin = File.join(user_home, ".profile.d", "user_bin")
  profile_bin_contents = <<-EOS
export PATH=#{user_bin}:$PATH
EOS
  
  met? { user_bin.p.dir? && profile_bin.p.file? && profile_bin.p.read == profile_bin_contents }
  meet { user_bin.p.create_dir; profile_bin.p.open("w+") {|f| f << profile_bin_contents }}
end

dep 'exuberant-ctags.managed' do
  provides "ctags"
end

dep "vundle", :user do
  requires 'git.managed'

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

Bundle 'https://github.com/majutsushi/tagbar.git'
Bundle 'https://github.com/altercation/vim-colors-solarized.git'
Bundle 'https://github.com/ervandew/supertab.git'
Bundle 'https://github.com/wincent/Command-T.git'
Bundle 'https://github.com/sjbach/lusty.git'

filetype plugin indent on

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

