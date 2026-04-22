{ config, ... }:

{
  age.secrets.agent_convergence_env = {
    file = ../../secrets/agent_convergence_env.age;
    owner = "agent-convergence";
    mode = "0400";
  };

  services.agent-convergence = {
    enable = true;
    environmentFile = config.age.secrets.agent_convergence_env.path;
  };
}
