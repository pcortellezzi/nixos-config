{ config, ... }:

{
  age.secrets.agent_convergence_env = {
    file = ../../secrets/agent_convergence_env.age;
    owner = "root";
    mode = "0400";
  };

  services.agent-convergence = {
    enable = true;
    environmentFile = config.age.secrets.agent_convergence_env.path;
    image = "ghcr.io/pcortellezzi/agent-convergence:main";
  };
}
