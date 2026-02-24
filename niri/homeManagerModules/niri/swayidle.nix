{pkgs, ...}:
let 
    lockcommand = "noctalia-shell ipc call lockScreen lock";
in {
  #TODO: make it work
services.swayidle = {
  enable = true;
  package = pkgs.swayidle;   

  timeouts = [
    { timeout = 330; command = lockcommand; }
    { timeout = 360; command = "niri msg action power-off-monitors";  
      resumeCommand = "niri msg action power-on-monitors"; }
  ];

  events = [
    { event = "before-sleep"; command = lockcommand; }
    { event = "after-resume"; command = lockcommand; }
  ];
};
}
