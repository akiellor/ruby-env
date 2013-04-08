require 'etc'

dep "rbenv", :user do
  requires 'rbenv.git'.with(:user => user, :commit => "7a10b64cf7e4df3261dec94f3c609a64a04998ef")
  requires 'rbenv.profile'.with(:user => user)
end

dep "rbenv.git", :user, :commit do
  user_home = Etc.getpwnam(user).dir
  rbenv = File.expand_path(".rbenv", user_home)
 
  met? { `git --git-dir=\"#{File.join(rbenv, ".git")}\" log HEAD...HEAD~1 --format=%H`.strip == commit}
  meet {
     shell! "git clone git://github.com/sstephenson/rbenv.git #{rbenv}"
     shell! "chown -R #{user} #{rbenv}"
     shell! "cd #{rbenv} && git reset --hard #{commit}"
  }
end

dep "rbenv.profile", :user do
  requires '.profile.d'.with(:user => user)
  
  user_home = Etc.getpwnam(user).dir
  rbenv_profile = File.expand_path(File.join(".profile.d", "rbenv"), user_home)
  rbenv = File.expand_path(".rbenv", user_home)
  rbenv_bin = File.expand_path("bin", rbenv)

  rbenv_profile_contents = "export PATH=\"#{rbenv_bin}:$PATH\""
 
  met? { rbenv_profile.p.file? && rbenv_profile.p.read == rbenv_profile_contents }
  meet { rbenv_profile.p.open("w+") {|f| f << rbenv_profile_contents } }
end

dep ".profile.d", :user do
  user_home = Etc.getpwnam(user).dir
  dot_profile_d = File.join(user_home, ".profile.d")
  dot_profile = File.join(user_home, ".profile")
  dot_profile_content = <<-EOS
#!/bin/sh

for FILE in $(find ~/.profile.d | tail -n-1); do source $FILE; done
EOS
  
  met? { dot_profile_d.p.dir? && dot_profile.p.file? && dot_profile.p.read == dot_profile_content }
  meet {
    dot_profile.p.open("w+") {|f| f << dot_profile_content }
    dot_profile_d.p.create_dir
  }
end
