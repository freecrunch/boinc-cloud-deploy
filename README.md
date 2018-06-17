
<img src="https://pasteboard.co/images/HqcBMsm.png/download" width="60%" height="60%">
# boinc-cloud-deploy
Automatically deploy BOINC projects to freshly-deployed cloud server instances. Part of the FreeCrunch project: [https://freecrunch.github.io/](https://freecrunch.github.io/)

# What is this?
This script will run a fully-configured deployment for cloud server instances to install, configure & setup a headless BOINC client.

It will download the client software, download an optional command line GUI for administrative tasks and also create an account on and attach to the BOINCStats Account Manager website for simpler system operation. It's not that this is particularly hard to do, but if you're lazy then it will certainly help. By making this process as hassle-free as possible more people will hopefully be encouraged to join the project.

# What this isn't
This isn't a container solution. Although the premise of containers can be useful for BOINC deployments in order to keep things simple this is a standard install to your actual server.

# How to use
Dead simple. Clone the repository, change to its directory, and run the following:

```
chmod +x install.sh
sudo install.sh
```

Then follow the prompts.

# Contact
Feel free to contact us via the details on our bio or post an issue.
