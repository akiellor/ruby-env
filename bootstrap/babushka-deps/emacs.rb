dep 'emacs24', :user do
  requires 'emacs-deps:emacs24.managed'
  requires "emacs24.config".with(:user => user)
end

dep 'emacs24.config', :user, :template => 'file-deps:owner_file' do
  owner user
  group user

  source File.join(".emacs.d", "init.el")
  target File.join(".emacs.d", "init.el")
end

