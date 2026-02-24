{pkgs, inputs, config,...}:
{
flake.nixosModules.snapper = {pkgs, inputs, ...}: 
{
  services.snapper = {
    configs = {
      root = {
        SUBVOLUME = "/";
        FSTYPE = "btrfs";
        QGROUP = "";
        SPACE_LIMIT = "0.5";
        FREE_LIMIT = "0.2";
        ALLOW_USERS = [];
        ALLOW_GROUPS = [];
        SYNC_ACL = "no";
        BACKGROUND_COMPARISON = true;
        NUMBER_CLEANUP = true;
        NUMBER_MIN_AGE = "3600";
        NUMBER_LIMIT = "50";
        NUMBER_LIMIT_IMPORTANT = "10";
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_MIN_AGE = "3600";
        TIMELINE_LIMIT_HOURLY = "0";
        TIMELINE_LIMIT_DAILY = "2";
        TIMELINE_LIMIT_WEEKLY = "2";
        TIMELINE_LIMIT_MONTHLY = "0";
        TIMELINE_LIMIT_QUARTERLY = "0";
        TIMELINE_LIMIT_YEARLY = "0";
        EMPTY_PRE_POST_CLEANUP = true;
        EMPTY_PRE_POST_MIN_AGE = "3600";
      };

      home = {
        SUBVOLUME = "/home";
        FSTYPE = "btrfs";
        QGROUP = "";
        SPACE_LIMIT = "0.5";
        FREE_LIMIT = "0.2";
        ALLOW_USERS = [];
        ALLOW_GROUPS = [];
        SYNC_ACL = "no";
        BACKGROUND_COMPARISON = true;
        NUMBER_CLEANUP = true;
        NUMBER_MIN_AGE = "3600";
        NUMBER_LIMIT = "50";
        NUMBER_LIMIT_IMPORTANT = "10";
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_MIN_AGE = "3600";
        TIMELINE_LIMIT_HOURLY = "5";
        TIMELINE_LIMIT_DAILY = "10";
        TIMELINE_LIMIT_WEEKLY = "0";
        TIMELINE_LIMIT_MONTHLY = "3";
        TIMELINE_LIMIT_QUARTERLY = "0";
        TIMELINE_LIMIT_YEARLY = "0";
        EMPTY_PRE_POST_CLEANUP = true;
        EMPTY_PRE_POST_MIN_AGE = "3600";
      };
    };
  };
};
}