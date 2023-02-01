{ pkgs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [ pkgs.git ];

  enterShell = ''
    hello
    git --version
  '';

  # https://devenv.sh/languages/
  languages.nix.enable = true;
  languages.elixir.enable = true;
  languages.elixir.package = pkgs.elixir_1_14;

  # https://devenv.sh/scripts/
  scripts.hello.exec = "echo hello from $GREET";

  # https://devenv.sh/pre-commit-hooks/
  pre-commit.hooks.shellcheck.enable = true;

  # https://devenv.sh/processes/
  # processes.ping.exec = "ping example.com";

  services.postgres.enable = true;
  services.postgres.initialDatabases = [
    { name = "match_dev"; }
    { name = "match_test"; }
  ];
  services.postgres.initialScript = "CREATE USER postgres SUPERUSER;";
}
