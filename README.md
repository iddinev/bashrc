# iddinev's bashrc

Feel free to fork/modify/borrow to cover your own needs.  
Obviously read the whole script before using it.

## Features
- The script is intentionaly not named '.bashrc' so users can/have the option to save their initial .bashrc
  befure using this one (and have the option to clean/revert to their configs if they don't like this one).
- The script can deploy the .bashrc configs separately from the plugin configs. Sources are fetched
  from github using wget.
- The script initializes 2 local git repos: to manage config files in $HOME and to manage
  local overrides/additions of the .bashrc itself. When reverting, these repos are intentionally not removed  
  so the user can double check if he needs to save something before removing them.
  
## Plugins currently used
- Powerline:
  https://github.com/iddinev/bash-powerline  

## Usage:
```bash
	$ source bashrc [options]


	Options:
		-d | --deploy    Download & setup the latest bashrc from github.
		-p | --plugins   Download & setup the latest plugins from github.
		-u | --uninstall Revert previous bashrc and remove plugins.
		-h | --help      Show this help message, don't download/setup/modify files.

	All the options also source the configs.
```
