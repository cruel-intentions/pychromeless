{ pre-commit-hooks }:
{
  pre-commit-check = pre-commit-hooks.run {
    src = ./.;
    hooks = {
      nixpkgs-fmt.enable = true;
      black.enable = true;
    };
  };
}
