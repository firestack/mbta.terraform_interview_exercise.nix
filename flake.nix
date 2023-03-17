{
	description = "virtual environments";

	inputs.devshell.url = "github:numtide/devshell";
	inputs.flake-utils.url = "github:numtide/flake-utils";

	outputs = { self, flake-utils, devshell, nixpkgs }:
		flake-utils.lib.eachDefaultSystem (system: {
			devShells.default =
				let
					pkgs = import nixpkgs {
						inherit system;

						overlays = [ devshell.overlays.default ];
					};
				in
				pkgs.devshell.mkShell {
					packages = [
						pkgs.terraform
						pkgs.python
						pkgs.colima
						pkgs.localstack
					];
				};
		});
}
