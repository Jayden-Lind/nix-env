{ ... }:

{
  programs.git = {
    enable = true;
    extraConfig = {
      user = {
        name = "Jayden Lind";
        email = "jaydenlind@gmail.com";
      };
      core.autocrlf = "input";
      init.defaultBranch = "main";
    };
  };
}
