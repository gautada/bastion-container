# bastion-container
A bastion extension for the alpine container.

### Bastion Server

Bastion is the access to the container. To setup the bastion server, i.e. the ssh server

### Services
- Environments 
 - Profile
- Timezones
- Sudo
- Versioning
- Healthcheck
- Entrypoint
- Bastion
- Scheduler



```
docker exec --user root /usr/bin/ssh-keygen
```

#### Bastion

A [bastion](https://en.wikipedia.org/wiki/Bastion_host) is a networking host that is designed to withstand external attacks.  This container service uses the bastion concept as a point of entry for accessing the container and the services within. This service is implemented with [openssh](https://www.openssh.com). The primary mechanism for interacting with the container should remain using the `podman[docker] exec` function however the bastion service allows for external control when configured and pod-to-pod control when in a k8s cluster.

Basic setup is an sshd service on port `22`.  With `PermitRootLogin no` and `PasswordAuthentication no`, so no root logins allowed and no password based logins. To use provide a bastion folder via `volume` or an nfs volume for k8s.

When running local setup access via the `--port 22:2222` mapping and the ssh keys are mapped via `--volume ~/Workspace/alpine/bastion:/opt/bastion`. **Note:** `.gitignore` should be updated to not include the local bastion folder.

For security bastion cannot run out-of-the box, you must create the server keys and the authorized_keys file.  These keys are provided via the bastion folder/volume from the host so once created they should work from each reboot.  Running locally the **first run** of the container must be restarted after setup to get the bastion service started or use a generic alpine container to create the bastion folder/volume before first run.

```
docker exec --interactive --tty --user root alpine /usr/bin/bastion-setup
```

Gnerally, containers use only one **USER**.  Therefore, the generic `/opt/bastion/ssh` folder that contains the `authorized_keys` file should be owned and constrained for the single **USER**.
