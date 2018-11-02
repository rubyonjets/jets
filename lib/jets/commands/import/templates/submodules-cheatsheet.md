# Git Submodule Cheatsheet

Git submodules take a little bit of getting used to. This is a cheatsheet for Git Submodules to help learn how to use them.  This file was generated as part of the `jets <%= @import_command %>` command.

## Cheatsheet Summary

The important submodule commands are:

### On fresh clone project

    git clone <%= @jets_project_repo_url %>
    git submodule init # required on a fresh clone, or update won't do anything
    git submodule update # syncs submodule rack folder with what parent project has as commits

### Updating

After doing a git pull on the Jets main project, you might notice changes to the submodule rack folder, you can update the rack folder with:

    git submodule update # syncs submodule rack folder with what parent project has as commits

## More Details

The rest of the guide will explain in a little more detail submodules.

## What are Git Submodules?

Git submodules are a way to have a subfolder in your project be managed as a separate git repo.  The submodule folder is its own separate git repo and has its own history. The parent git project references a commit from the submodule project to sync up the subfolder accordingly.  Using submodules allows you to include a rack subfolder project into your Jets project code base and managed the rack project as a separate git repo.

By using the `--submodule` option when you run the `jets import` command, Jets imports the rack project to the rack folder as a submodule.  This allows you to keep development of the rack project independent from the development of the Jets project. This is a useful setup if you are testing [Jets Mega Mode](http://rubyonjets.com/docs/megamode/) for more extended periods of time.

We'll show you how to managed and sync the `rack` submodule folder with the parent Jets project folder.

### rack submodule

A rack folder was added to your Jets project as a git submodule.  Essentially this command was run.

    git submodule add --force <%= @rack_repo_url %> rack

The rack submodule folder gets immediately synced as a part of that `git submodule add` command.  This has already happened as part of the `jets <%= @import_command %>, we're just explaining the underlying command in case you're interested.

### Fresh Clone

**IMPORTANT**: On a fresh clone of your project, submodule folders do not automatically update and appear "empty".  This can be confusing for people who don't use submodules often. So here are the commands to update and sync the submodule folder:

    git clone <%= @jets_project_repo_url %>
    git submodule init # important to run init or next update will do nothing
    git submodule update # after this the rack folder will no longer be empty
                         # and will have code from <%= @rack_repo_url %>

### Remove submodule

If you ever decide to remove the submodule from your project, here are the commands.

    git submodule deinit rack
    git rm rack
    # then add and commit your changes

## Updating Projects

The typical workflow is to go into the rack folder and run `git pull` to update the submodule folder to the latest changes. Then you cd back up to the main Jets project folder and run `git add`.  This updates the project submodule commit reference, which then allows others to pull down the changes and resync the submodules to the same commit. We'll go through some examples to help explain:

### Updating rack folder submodule

Here's an example where we will update the rack submodule folder to the latest `master` branch. Remember the master branch refers to the `rack` submodule folder of the <%= @rack_repo_url %> in this case.

    cd my-jets-project # root of the Jets project
    cd rack # in the submodule now, which contains a different repo history
    git checkout master # on a fresh clone, the submodule folder will point to a specific git sha instead of a branch
    git pull # get latest changes in master
    cd .. # back to parent Jets project
    git status # notice, it'll say: modified:  rack (new commits)
    git add rack # updates the main projects' reference to the submodule git commit
    git commit -m "update rack submodule"
    git push # send your changes to everyone else

Eventually, later another developer will pull down your changes on the Jets project and notice that the submodules have been updated.  When he runs a `git pull` and then does a `git status` he'll notice this:

    $ git pull # another developer pulled down the changes
    $ git st # notice the changes
        modified:   rack (new commits)
    $ git diff # another way a summary of the changes in the rack project
    Submodule rack 6b0fb3a..4f6ea3f (rewind):
      < test commit in rack submodule project

This is when the developer will need to resync the rack submodule folder. He does it with this:

    git submodule update # updates the rack folder to the commit that the parent is referencing

That's it!
