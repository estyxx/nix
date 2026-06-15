# Cursor editor settings (VS Code–compatible JSON).
{ machineConfig, ... }:
{
  home.file."Library/Application Support/Cursor/User/settings.json".source =
    if machineConfig.profile == "kraken" then ./cursor/settings-kraken.json else ./cursor/settings.json;
}
