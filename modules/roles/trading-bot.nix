{ config, ... }:

{
  age.secrets.trading_bot_env = {
    file = ../../secrets/trading_bot_env.age;
    owner = "trading-bot";
    mode = "0400";
  };

  services.trading-bot = {
    enable = true;
    environmentFile = config.age.secrets.trading_bot_env.path;
    logLevel = "info";
  };
}
