{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Jayden Lind";
        email = "jaydenlind@gmail.com";
      };
      core.autocrlf = "input";
      init.defaultBranch = "main";
    };
  };
}
