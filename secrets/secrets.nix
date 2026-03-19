let
  # User keys
  philippe = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXzXVwhvs1e8TbnSRBqmze0MbyT1HMmpgzsnNfTrrIx philippe@nixos-config";

  # Host keys
  ser5 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMmKACbEYcQJh4zFC2OOfTHnuHJFZsX30wDxiX80vAy0 root@ser5";
  vvb = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKz6TlHtF36oDpze5d8BlgZssp0GRPudT9+MN0sgyQcL root@vvb";
  flip-cx5 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0jT2LqxqqWoeCDZz4Jq7gyeQP1Iy90E1vQh/bSEuj0 root@flip-cx5";

  all = [ philippe ser5 vvb flip-cx5 ];
in
{
  # Shared secrets (all hosts)
  "philippe_ssh_id_ed25519.age".publicKeys = all;
  "wifi_Livebox-7360_EXT.age".publicKeys = all;

  # ser5 only
  "aria2_rpc_token.age".publicKeys = [ philippe ser5 ];
  "ser5_host_key.age".publicKeys = [ philippe ser5 ];
  "trading_bot_env.age".publicKeys = [ philippe ser5 ];

  # Per-host keys
  "vvb_host_key.age".publicKeys = [ philippe vvb ];
  "flip-cx5_host_key.age".publicKeys = [ philippe flip-cx5 ];

  # Home-manager secrets (desktops)
  "../home/philippe/secrets/motivewave_license.age".publicKeys = [ philippe vvb flip-cx5 ];
}
