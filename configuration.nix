{ config, lib, pkgs, ... }:

{
  programs.nix-ld = {
    enable = true;
    libraries = [ pkgs.icu ];
  };


  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
    extraPackages = [ pkgs.podman-compose ];
  };  


  programs.nano = {
    enable = true;
    nanorc = ''
      set tabsize 2
      set autoindent
      set tabstospaces
    '';
  };


  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd sway";
      user = "greeter";
    };
  };


  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = ["*"];
      extraConfig = ''
        [main]
        capslock = layer(meta)
        rightshift = end
        rightalt = home
        leftmeta = rightmeta
      '';
    };
  };


  services.mysql = {
    enable = true;
    package = pkgs.mysql84;
  };
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "victor" ];
    ensureUsers = [
      { name = "victor"; ensureDBOwnership = true; }
    ];
  };


  services.gnome.gnome-keyring.enable = true;
  services.libinput.enable = true;
  services.printing.enable = true;
  services.openssh.enable = true;
  services.gvfs.enable = true;  
  services.devmon.enable = true;
  services.udisks2.enable = true;
  security.polkit.enable = true;


  # screensharing
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [ 
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr  
    ];    
    config.common = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
    };
  };
  environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];


  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      font-awesome
      source-han-sans
      nerd-fonts._3270
      nerd-fonts.agave
      nerd-fonts.mononoki
    ];
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" "Source Han Serif" ];
      sansSerif = [ "Noto Sans" "Source Han Sans" ];
      monospace = [ "Mononoki Nerd Font Mono" "Noto Sans Mono" ];
    };
  };


  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";


  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.enable = false;
  };


  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;  
  nix.settings.trusted-users = [ "root" "victor" ];


  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };


  users.users.victor = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "input"
      "disk"
      "podman"
    ];
  };


  imports = [ ./hardware-configuration.nix ];
  system.stateVersion = "26.05";
}
