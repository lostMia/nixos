{ secretsDir, inputs, ... }:
{
	users.users.me = {
   	isNormalUser = true;
   	passwordFile = "${secretsDir}/me-pwd";
   	extraGroups = [ "networkmanager" "wheel" "libvirtd" ]; # Enable ‘sudo’ for the user.

	};

	#home-manager._module.args = { inherit inputs; };
	home-manager.users.me = import ./home.nix;
}
