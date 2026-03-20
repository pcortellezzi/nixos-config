{ config, ... }:

{
  age.secrets.trading_bot_env = {
    file = ../../secrets/trading_bot_env.age;
    owner = "trading-bot";
    mode = "0400";
  };

  services.trading-bot = {
    enable = true;

    rithmic = {
      system_name = "Rithmic Paper Trading";
      gateway = "Chicago Area";
    };

    starting_equity = 150000.0;
    max_drawdown = 4500.0;
    trail_until = 150100.0;

    default_sizing = "onrb_funded";
    sizing_strategies.onrb_funded = {
      pre_lock = { type = "fixed_nq"; contracts = 1; };
      post_lock = { type = "log2"; base_dd = 2250.0; };
      max_contracts = 17;
    };

    instruments = [{
      symbol = "NQ";
      exchange = "CME";
      micro_symbol = "MNQ";
      mode = "dry-run";
      state_file = "state/nq.json";
      tick_size = 0.25;
      point_value = 20.0;
      micro_point_value = 2.0;
      strategies = [ "ONRB trail LONG" "ONRB trail SHORT" ];
    }];

    environmentFile = config.age.secrets.trading_bot_env.path;
    logLevel = "info";
  };
}
