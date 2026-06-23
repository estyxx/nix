# Oh My Fish from nixpkgs: framework lives in the store; user packages/themes live under
# $OMF_CONFIG (~/.config/omf). Run `omf install default` once if you have no packages yet.
{ pkgs, ... }:
{
  home.packages = [ pkgs.oh-my-fish ];

  home.sessionPath = [ "${pkgs.oh-my-fish}/share/oh-my-fish/bin" ];

  xdg.configFile."fish/conf.d/00-oh-my-fish.fish".text = ''
    # Oh My Fish (nixpkgs): read-only OMF_PATH, writable OMF_CONFIG.
    set -q __fish_omf_nix_sourced
    and exit
    set -g __fish_omf_nix_sourced 1

    set -gx OMF_PATH ${pkgs.oh-my-fish}/share/oh-my-fish
    set -gx OMF_CONFIG $HOME/.config/omf

    if test -f $OMF_PATH/init.fish
      source $OMF_PATH/init.fish
    end
  '';
}
