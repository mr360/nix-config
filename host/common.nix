{lib, pkgs, ...}:
{
	networking.networkmanager.enable = true;  
	time.timeZone = "Australia/Sydney";
	hardware.graphics.enable = true;
	nixpkgs.config.allowUnfree = true;
}
