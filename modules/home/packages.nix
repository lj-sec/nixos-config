{ pkgs, inputs, ... }:
{
  # Packages listed here have no configuration of their own as of now
  home.packages = with pkgs; [
    
    # Desktop Environment
    #
    ## Clipboard
    wl-clip-persist
    cliphist
    wl-clipboard
    ## Browser
    firefox           # Backup for Brave weirdness
    ## File Explorer
    yazi              # For the CLI
    ## Calculator
    rink
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
    nix-search
    coreutils
    inetutils
    filezilla
    ripgrep
    gnused
    gawk
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
    terraform
    tflint
    ## Compression
    unzip
    gnutar
    p7zip
    ## Network
    openvpn
    wireguard-tools
    proxychains-ng
    ## Goofy
    cava
    sl                # choo-choo
    pay-respects      # f
    asciiquarium-transparent
    cowsay
    pipes
    lolcat
    waybar-lyric
    prismlauncher
    rpi-imager

    # GUI Tools
    #
    ## Calendar
    gnome-calendar
    ## Markdown
    obsidian
    ## Communication
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
    # dnsrecon
    macchanger
    ## Web
    # burpsuite
    # zap
    # sqlmap
    # wpscan
    # dirbuster
    ## Creds
    hashcat
    seclists
    ## Win/AD
    # netexec
    # evil-winrm
    # mimikatz
    # responder
    # powersploit
    # enum4linux-ng
    # smbclient-ng
    # smbmap
    # openldap
    # kerbrute
    ## Net
    tcpdump
    ## Wireless
    aircrack-ng
    ## Framework
    # metasploit
    # exploitdb
    ## Social Engineering
    # social-engineer-toolkit
    ## Post
    # dbd
    netcat
  ];
}
