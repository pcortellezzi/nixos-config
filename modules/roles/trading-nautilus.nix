{ config, inputs, ... }:

{
  age.secrets.trading_bot_env = {
    file = ../../secrets/trading_bot_env.age;
    mode = "0400";
  };

  services.trading-nautilus = {
    enable = true;
    image = "ghcr.io/pcortellezzi/trading-nautilus/nautilus-mr:${inputs.trading-nautilus.imageTag}";
    environmentFile = config.age.secrets.trading_bot_env.path;
    testnet = true;
  };
}
