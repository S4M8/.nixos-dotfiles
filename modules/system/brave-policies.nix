{ ... }: {
  environment.etc."brave/policies/managed/GroupPolicy.json".text = ''
    {
      "BraveRewardsDisabled": true,
      "BraveWalletDisabled": true,
      "BraveVPNDisabled": true,
      "BraveAIChatEnabled": false,
      "BraveNewsDisabled": true,
      "BraveTalkDisabled": true,
      "BraveSpeedreaderEnabled": false,
      "BraveP3AEnabled": false,
      "BraveStatsPingEnabled": false,
      "BraveWebDiscoveryEnabled": false,
      "TorDisabled": true,
      "MetricsReportingEnabled": false,
      "PasswordManagerEnabled": true,
      "BrowserSignin": 0
    }
  '';
}
