{ pkgs, ... }:

{
  environment.packages = with pkgs; [
    coreutils
    git
    curl
    wget
    openssh
    fish
    tmux
    nano
    vim
    ripgrep
    fd
    gnused
    gawk
    gnugrep
    jq
    eza
    bat
    fzf
    tree
    file
    less
    killall
    procps
    inetutils
    util-linux
    unzip
    gnutar
    gzip
    xz
    zip
    p7zip
    btop
    htop
    yazi
    dnsutils
    whois
    net-tools
    traceroute
    iproute2
    openssl
    socat
    nmap
    tcpdump
    netcat
    sqlmap
    gh
    pay-respects
    cowsay
    lolcat
  ];

  environment.etcBackupExtension = ".bak";

  user.shell = "${pkgs.fish}/bin/fish";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "24.05";

  home-manager = {
    config = ./home.nix;
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
