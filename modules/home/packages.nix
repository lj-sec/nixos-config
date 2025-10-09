{ pkgs, ... }:
{
  # Packages listed here have no configuration of their own as of now
  home.packages = with pkgs; [
    
    # Desktop Environment
    #
    ## Clipboard
    wl-clip-persist
    cliphist
    wl-clipboard
    ## File Explorer
    yazi              # For the CLI
    ## Media
    gimp              # Image editor
    mpv               # Video player
    imv               # Image player
    ffmpeg            # duh
    inkscape          # PDF handler, mainly, but a LOT can be done w/
    obs-studio        # Screen recording
    sticky            # Sticky Notes!
    ## Screenshots
    grim
    swappy

    # CLI Tools
    #
    ## Utils
    wget
    eza               # better ls
    killall
    file
    jq
    tree
    bat               # better cat
    fzf
    whois
    dnsutils
    net-tools
    traceroute
    util-linux
    ## Languages
    powershell
    ## Compression
    unzip
    gnutar
    p7zip
    ## Network
    wireguard-tools
    proxychains-ng
    ## Goofy
    sl                # choo-choo
    pay-respects      # f
    asciiquarium-transparent
    cowsay
    pipes
    lolcat

    # GUI Tools
    #
    ## Calendar
    gnome-calendar
    ## Markdown
    obsidian
    ## Communication
    discord
    signal-desktop
    slack
    ## Remote Management
    remmina
    ## Office
    libreoffice-fresh
    hunspell          # For spellcheck
    hunspellDicts.en_US
    # Music
    spotify

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
