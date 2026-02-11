{ ... }:
{
  programs.vscode.profiles.default = {
    userSettings = {
      "update.mode" = "none";
      "extensions.autoUpdate" = false;
      "window.titleBarStyle" = "custom";

      "window.menuBarVisibility" = "toggle";
      "editor.FontFamily" = "JetBrainsMono Nerd Font, monospace";
      "terminal.integrated.fontFamily" = "'Maple Mono', 'SymbolsNerdFont'";
      "editor.fontSize" = 16;
      "editor.columnSelection" = true;
      "editor.selectionClipboard" = false;
      "editor.scrollOnMiddleClick" = false;
      "workbench.colorTheme" = "Catppuccin Mocha";
      "explorer.confirmDragAndDrop" = false;
    };
  };
}