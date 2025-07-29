{
  services.openssh = {
    enable = true;
    startWhenNeeded = false;
    openFirewall = true;
  };
}
