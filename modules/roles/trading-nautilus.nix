{ config, ... }:

{
  age.secrets.trading_bot_env = {
    file = ../../secrets/trading_bot_env.age;
    owner = "trading-nautilus";
    mode = "0400";
  };

  services.trading-nautilus = {
    enable = true;
    environmentFile = config.age.secrets.trading_bot_env.path;
    testnet = true;
  };
}
