{ pkgs, lib, installFeatures ? {}, ... }:
let
  feature = name:
    if builtins.hasAttr name installFeatures then installFeatures.${name} else true;
in
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
    ## Notes
    sticky            # Sticky Notes!
    ## Screenshots
    grim
    swappy

    # CLI Tools
    #
    ## Utils
    codex
    wev
    keyd
    nix-search
    coreutils
    inetutils
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
    ## Compression
    unzip
    gnutar
    p7zip
  ]

  ++ lib.optionals (feature "media") [
    # Media and creative tools
    #
    ## Media
    losslesscut-bin   # Video cutter
    handbrake         # Video converter
    gimp              # Image editor
    mpv               # Video player
    imv               # Image player
    ffmpeg            # duh
    inkscape          # PDF handler, mainly, but a LOT can be done w/
    obs-studio        # Screen recording
  ]

  ++ lib.optionals (feature "remote") [
    # Remote access, VPN, and imaging tools
    #
    filezilla
    openvpn
    wireguard-tools
    remmina
    rpi-imager
  ]

  ++ lib.optionals (feature "fun") [
    # Fun and gaming-adjacent tools
    #
    benhsm-minesweeper
    sl                # choo-choo
    pay-respects      # f
    asciiquarium-transparent
    cowsay
    pipes
    lolcat
    prismlauncher
  ]

  ++ lib.optionals (feature "music") [
    # Music
    #
    cava
    waybar-lyric
    spotify
  ]

  ++ lib.optionals (feature "office") [
    # GUI Tools
    #
    ## Calendar
    gnome-calendar
    ## Markdown
    obsidian
    ## Office
    libreoffice-fresh
    hunspell          # For spellcheck
    hunspellDicts.en_US
  ]

  ++ lib.optionals (feature "communication") [
    # Communication
    #
    signal-desktop
    slack
  ]

  ++ lib.optionals (feature "security") [
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
  ]

  ++ lib.optionals (feature "devops") [
    # Terraform and Ansible management
    #
    powershell
    tflint
    terraform
    ansible
    python3Packages.pypsrp
    python3Packages.pywinrm
    krb5
    ansible-lint
  ];
}
