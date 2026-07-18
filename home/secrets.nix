{ config, ... }:

# Secrets are sops-encrypted files in secrets/, committed to git.
# They are decrypted at activation using the age key in
# ~/.config/sops/age/keys.txt (NOT in git — copy it between machines
# manually, and keep a backup: losing it means losing the secrets).
#
# Add a new secret:
#   sops encrypt --input-type binary --output-type binary /path/to/file > secrets/<name>
#   ...then declare it below and point its `path` where the tool expects it.
# Edit an existing secret in place:
#   sops edit secrets/<name>
{
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    secrets.kubeconfig = {
      sopsFile = ../secrets/kubeconfig;
      format = "binary";
      path = "${config.home.homeDirectory}/kubeconfig.conf";
    };
  };
}
