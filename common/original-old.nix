# eg.
# ln -sf /home/me/nixos-config/nspawn/configuration.nix  /etc/nixos/configuration.nix

{ lib,  pkgs, ... }:
with lib;

{
  #imports = [ <nixpkgs/nixos/modules/virtualisation/lxc-container.nix> ];


  # how can we import from a local file.

  # config.networking.hostName = "nixos03"; # Define your hostname.

  # Select internationalisation properties.
  #config.i18n = {
  #  consoleFont = "Lat2-Terminus16";
  #  consoleKeyMap = "us";
  #  # defaultLocale = "en_US.UTF-8";
  #  defaultLocale = "en_AU.UTF-8";
#
#  };

  # Set your time zone.
  # time.timeZone = "Australia/Hobart";


  # Enable the OpenSSH daemon.
  config.services.openssh.enable = true;
  config.services.openssh.permitRootLogin = "without-password";
  # JA usePAM is default
  # think would need the %u is user, %h is home /root/.ssh...
  # services.openssh.authorizedKeysFiles = ["%h/.ssh/authorized_keys"];

  # services.openssh.authorizedKeysFiles = ["/root/.ssh/authorized_keys"];

  # services.openssh.authorizedKeysFiles = ["~/.ssh/authorized_keys"];
  config.users.extraUsers.root.openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDd9DazuhCPLh9YcW8BtHTIWZ+k4ZXo7TtI55f2r/r1MXF/odbQsYb+lJmLMStp8ncHyH7YUaWBvWlz6q9ourkXixYuf255NjrVxBsnqWW58xPwtnRz7jVtVr2oBuId8Uf1o4HCou2a5vLRhuajq6Xd/VHz4z2kpcCsdObiteHqzrLCoZCtDlKxlcGADC057OqZM1FrIV1+2T5ZnN/PDwXphK0D+ZnHm2Sd5n0prpR4NfVtnlq3/68o5xzS2Wm4FhHXF2DqDzolC6OnPWHMqYNXn2vbmQD05Ef4iix0O8cYQ888QQ4/cUnW4ONPPCk1ixv8xqpXsLSAt8EdQjQsZRHB me" ];


  config.networking.firewall.enable = false;


  # currently needed for ansible to run dotfiles deploy
  config.users.extraGroups.me.gid = 1000;

  config.users.extraUsers.me =
   { isNormalUser = true;
     home = "/home/me";
     description = "my description";
     extraGroups = [ "me" "wheel" "networkmanager" ];
     openssh.authorizedKeys.keys =
        [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDd9DazuhCPLh9YcW8BtHTIWZ+k4ZXo7TtI55f2r/r1MXF/odbQsYb+lJmLMStp8ncHyH7YUaWBvWlz6q9ourkXixYuf255NjrVxBsnqWW58xPwtnRz7jVtVr2oBuId8Uf1o4HCou2a5vLRhuajq6Xd/VHz4z2kpcCsdObiteHqzrLCoZCtDlKxlcGADC057OqZM1FrIV1+2T5ZnN/PDwXphK0D+ZnHm2Sd5n0prpR4NfVtnlq3/68o5xzS2Wm4FhHXF2DqDzolC6OnPWHMqYNXn2vbmQD05Ef4iix0O8cYQ888QQ4/cUnW4ONPPCk1ixv8xqpXsLSAt8EdQjQsZRHB me" ];
   };


  config.users.users.root.packages =
            with pkgs;[ vim git screen less man psmisc ];


  config.users.users.me.packages =

  # system is mostly unusable without a good working vim.
  # note we symlink config files, so not really needed for root.
  # https://www.mpscholten.de/nixos/2016/04/11/setting-up-vim-on-nixos.html
  let


    myVim =
    pkgs.vim_configurable.customize {
        # Specifies the vim binary name.
        name = "vim";
        # CHANGE this - to just read a file from dotfiles
        vimrcConfig.customRC = builtins.readFile ( ../dotfiles/vimrc ) ;
        # dec 2019. Install dotfiles by hand

        vimrcConfig.packages.myVimPackage = with pkgs.vimPlugins; {
          # loaded on launch
          start = [ vim-nix  ];

          # manually loadable by calling `:packadd $plugin-name`
          # opt = [ phpCompletion elm-vim ];
          # To automatically load a plugin when opening a filetype, add vimrc lines like:
          # autocmd FileType php :packadd phpCompletion
        };
    };

    # likewise for git
    # https://qnikst.github.io/posts/2018-08-22-long-live-dotfiles.html
    # https://github.com/qnikst/homster/tree/master/git
    myGit =
      pkgs.git.overrideAttrs (old: {
        configureFlags = [ "--with-gitconfig=$out/etc/gitconfig" ];
        postInstall = ''
          mkdir $out/etc/
          cp "${../dotfiles/gitconfig}" $out/etc/gitconfig
        '';
      });


    #myScreen = {
    #    text = builtins.readFile ( "${/home/me/nixos-config/dotfiles/screenrc}"  ) ;
    #    mode = "0444";
    #  };



  in

  # note less, nc, netstat, curl, rsync are installed by default
  with pkgs;

  [ myVim myGit screen less man psmisc ];

  config.environment.etc = {

    # Whoot. fixed screen message. uses /etc/screenrc
    # eg. nix-repl> pkgs.screen.configureFlags
    # [ "--enable-telnet" "--enable-pam" "--with-sys-screenrc=/etc/screenrc" "--enable-colors256" ]
    # screenrc = myScreen;

    screenrc = {
        text = builtins.readFile ( ../dotfiles/screenrc ) ;
        mode = "0444";
      };

    # bashrc/ bash_aliases
    "bashrc.local" = {
      text = builtins.readFile ( ../dotfiles/bashrc ) ;
      mode = "0444";
    };

  };


   config.system.activationScripts =  {

    #  do this for root also???
    myfiles =
        ''
        echo "making local vim dirs"
        for i in ".vim" ".vim/backup" ".vim/swap"  ".vim/undo" ".vim/autoload" ".vim/bundle"; do
          # echo $i;
          [ -d "/home/me/$i" ] || mkdir "/home/me/$i" && chown me: "/home/me/$i"
        done
        '';

    };


}

