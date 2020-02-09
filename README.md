# iddinev's bashrc

Feel free to fork/modify/borrow to cover your own needs.  
Obviously read the whole script before using it.

## Features
- The script is intentionaly not named '.bashrc' so users can (and have the option to) save their initial .bashrc
  befure using this one (and have the option to clean/revert to their configs if they don't like this one).
- The script can deploy the .bashrc configs separately from the plugin configs. Sources are fetched
  from github using wget.
- The 1st time the script is manually sourced it backups the preexisting .bashrc (if any),
  afterwards it moves itself to '$HOME/.bahsrc' and deletes the now uneeded git dir.
- Local git repos to manage bashrc overrides/additions and modifications of the $HOME
  can be created (and have command aliases).
- When reverting, the local repos are intentionally not removed
  so the user can double check if something has to be saved before removing them.
- Minimal env clutter - the internal functions deployed by the script are eval'ed
  so they don't need any variables to remain exported just for them. Internal variables are
  unset at the end of the script.
  
## Plugins currently used
- Powerline:
  https://github.com/iddinev/bash-powerline  

- fzf:
  https://github.com/junegunn/fzf

## Usage:
```bash

    Usage:
    1)
      $ source bashrc:

         Sources the configs and makes the functions from 2) available.
         Implies '$ bashrc_update; bashrc_update -c'.

    2)
      $ bashrc_update [ -c ]

         Backup the preexisting .bashrc & update it to the latest bashrc from github.
         Consecutive updates do not rewrite the initial backup.

         -c, --create-local-git
             Create local git repos to manage local \$HOME & .bashrc modifications.

     $ bashrc_plugins_update

         Update to the latest plugins from github.

     $ bashrc_uninstall

         Reverts to the old bashrc & removes plugins.
         Intentionally does not remove the local git repos.
         If used, check if you need to save something from them and
         remove them manually.

     $ bashrc_help

         Show this help message.

```
