# Berkflow

A command line tool for managing Chef Environments using Berkshelf and the [Environment Cookbook Pattern](http://blog.vialstudios.com/the-environment-cookbook-pattern/).

> TLDR of the Environment Cookbook Pattern; You have one top level cookbook that is locked to a Chef Environment. One application per Chef Environment. This Chef Environment is named `{application_name}-{environment}` (i.e. "myface-dev").


### Note

This project is currently unmaintained. It may work, but we would advise against adopting this workflow if you are a new user.

## Requirements

- [Chef-DK](https://downloads.chef.io/chef-dk/) >= 0.2.0

## Installation

Install the [Chef-DK](https://downloads.chef.io/chef-dk/) and add it, and it's gem binaries directory to your path

```shell
$ export PATH=/opt/chefdk/bin:$HOME/.chefdk/gem/ruby/2.1.0/bin:$PATH
```

Install Berkflow into the ChefDK

```shell
$ chef gem install berkflow
$ which blo
/Users/reset/.chefdk/gem/ruby/2.1.0/bin/blo
```

## Usage

```shell
$ blo help
```

### Upgrading a Chef Environment

Berkflow exposes a command for configuring a Chef Environment to a specific Environment Cookbook version and running Chef Client on all nodes in that environment.

```shell
$ blo upgrade myface-dev myface 1.2.3
Applying cookbook locks to myface-dev...
Discovering nodes in myface-dev...
Running Chef Client on 10 nodes...
Successfully ran Chef Client on 10 nodes
Done. See berkflow_out/20140331172904 for logs.
```

You can also upgrade to the latest version of the cookbook found on the Chef Server by passing `latest`

```shell
$ blo upgrade myface-dev myface latest
```

or simply leaving the version blank

```shell
$ blo upgrade myface-dev myface
```

Your Chef Server must meet the following requirements:

- The `myface-dev` environment must exist
- Version 1.2.3 of the myface cookbook (and it's dependencies) must be uploaded to the server
- Version 1.2.3 of the myface cookbook must have a Berksfile.lock. A cookbook having a Berksfile.lock is said to be an "Environment Cookbook"

> Note: earlier versions of Berkshelf generated a chefignore file that included the Berksfile.lock. This will prevent your Berksfile.lock from being uploaded. Remove this line from the chefignore of your cookbook. This has been fixed in Berkshelf master and will ship with Berkshelf 3.0.

By default, the user you are logged into your current machine and your default id_rsa key will be used for SSH authentication. See the help menu for how to override SSH settings.

### Running Chef Client on a Chef Environment

Berkflow has you covered if you just want to run Chef Client on all the nodes in your Chef Environment.

```
$ blo run_chef myface-dev
Discovering nodes in myface-dev...
Running Chef Client on 10 nodes...
Successfully ran Chef Client on 10 nodes
Done. See berkflow_out/20140331180610 for logs.
```

### Running shell commands on a Chef Environment

Running arbitrary shell commands is possible, too!

```
$ blo exec myface-dev "ls -lah"
Discovering nodes in myface-dev...
Executing command on 10 nodes...
Successfully executed command on 10 nodes
Done. See berkflow_out/20140331180708 for logs.
```

Shell commands executed with `blo exec` are by default not run with sudo. Use the --sudo flag to elevate.

```shell
$ blo exec myface-dev "ls -lah" --sudo
```

### Installing Berkshelf packages into a Chef server

Packages generated by `berks package` can be easily installed into a Chef Server with Berkflow.

```shell
$ blo install https://github.com/berkshelf/berkshelf-cookbook/releases/download/v0.3.1/cookbooks.tar.gz
```

It works with filepaths, too

```
$ blo install cookbooks.tar.gz
```

Installing a package will upload and freeze each cookbook into your configured Chef Server. Already frozen cookbooks will be skipped unless you specify the --force flag.

```
$ blo install cookbooks.tar.gz --force
```

## Contributing

1. Fork it ( <https://github.com/reset/berkflow/fork> )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Author

Jamie Winsor ([jamie@vialstudios.com](mailto:jamie@vialstudios.com))
