# Nix-managed Fish plugins (replaces Fisher for reproducibility).
{ pkgs, ... }:
{
  programs.fish.plugins = [
    {
      name = "z";
      src = pkgs.fetchFromGitHub {
        owner = "jethrokuan";
        repo = "z";
        rev = "e0e1b57";
        sha256 = "sha256-+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
      };
    }
    {
      name = "done";
      src = pkgs.fetchFromGitHub {
        owner = "franciscolourenco";
        repo = "done";
        rev = "eb32ade";
        sha256 = "sha256-DMIRKRAVOn7YEnuAtz4hIxrU93ULxNoQhW6juxCoh4o=";
      };
    }
    {
      name = "autopair";
      src = pkgs.fetchFromGitHub {
        owner = "jorgebucaran";
        repo = "autopair.fish";
        rev = "4d1752ff5b39819ab58d7337c69220342e9de0e2";
        sha256 = "sha256-qt3t1iKRRNuiLWiVoiAYOu+9E7jsyECyIqZJ/oRIT1A=";
      };
    }
    {
      name = "plugin-git";
      src = pkgs.fetchFromGitHub {
        owner = "jhillyerd";
        repo = "plugin-git";
        rev = "dd1f559c01cde4cf0d16581b60e20d29f33c0665";
        sha256 = "sha256-ByEqv5mZ6S9K+Pkpf1Dybwfqh3x++3AhXaMtw0I3wDo=";
      };
    }
    {
      name = "colored-man-pages";
      src = pkgs.fetchFromGitHub {
        owner = "patrickf3139";
        repo = "colored-man-pages";
        rev = "f885c2507128b70d6c41b043070a8f399988bc7a";
        sha256 = "sha256-ii9gdBPlC1/P1N9xJzqomrkyDqIdTg+iCg0mwNVq2EU=";
      };
    }
  ];
}
