{ pkgs, ... }:
{
  # Packages listed here have no configuration of their own as of now
  home.packages = with pkgs; [
    
    # Desktop Environment
    #
    ## Clipboard
    wl-clipboard
    ## File Explorer
    nemo
    yazi
    ## Media
    gimp
    mpv
    imv
    ffmpeg
    inkscape
    obs-studio
    ## Screenshots
    grim
    swappy

    # CLI Tools
    #
    ## Utils
    wget
    eza
    swappy
    killall
    file
    jq
    tree
    bat
    fzf
    dnsutils
    net-tools
    util-linux
    ## Compression
    unzip
    gnutar
    ## Network
    wireguard-tools
    proxychains-ng
    ## Goofy
    sl
    pay-respects
    asciiquarium-transparent
    cowsay
    pipes
    lolcat

    # GUI Tools
    #
    ## Communication
    discord
    signal-desktop
    ## Remote Management
    remmina
    ## Office
    libreoffice-fresh
    hunspell
    hunspellDicts.en_US

    # Security
    #
    ## Recon
    nmap
    dnsrecon
    macchanger
    ## Web
    burpsuite
    zap
    sqlmap
    wpscan
    dirbuster
    ## Creds
    hydra
    hashcat
    seclists
    ## Win/AD
    netexec
    evil-winrm
    mimikatz
    responder
    powersploit
    enum4linux-ng
    smbclient-ng
    smbmap
    openldap
    kerbrute
    ## Net
    wireshark
    tcpdump
    ## Wireless
    aircrack-ng
    ## Framework
    metasploit
    exploitdb
    ## Post
    dbd
    netcat
  ];
}