{ config, pkgs, ... }:
{
  home.sessionVariables.HYPRSHADE_SHADERS_DIR = "${config.xdg.configHome}/hypr/shaders:${pkgs.hyprshade}/share/hyprshade/shaders";

  xdg.configFile."hypr/shaders/dim20.frag".text = ''
    #version 300 es
    precision mediump float;

    uniform sampler2D tex;
    in vec2 v_texcoord;

    out vec4 fragColor;

    void main() {
        vec4 c = texture(tex, v_texcoord);
        fragColor = vec4(c.rgb * 0.8, c.a); // 20% dim
    }
  '';
  xdg.configFile."hypr/shaders/dim40.frag".text = ''
    #version 300 es
    precision mediump float;

    uniform sampler2D tex;
    in vec2 v_texcoord;

    out vec4 fragColor;

    void main() {
        vec4 c = texture(tex, v_texcoord);
        fragColor = vec4(c.rgb * 0.6, c.a); // 40% dim
    }
  '';
}