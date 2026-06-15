# home-manager overrides for machines with profile = "kraken"
{ ... }:
{
  programs.fish.shellAliases = {
    cdk = "cd ~/Projects/kraken-core";
    pcrun = "SKIP=pytest pre-commit run --files (git diff --name-only master)";
    t = "teamsearch";
    tf = "teamsearch find . -c .github/CODEOWNERS -t \"octoenergy/product-catalog\" -p";
  };
}
