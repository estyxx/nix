# direnv integration (uses Homebrew direnv if installed).
{ ... }:
{
  programs.fish.interactiveShellInit = ''
    if command -v direnv >/dev/null
      direnv hook fish | source
    end
  '';
}
