# cfncluster
create, customize, usage

- First thing first, work with a properly configued VPC. Make sure the instances launched in the VPC can communicate within permissions.
- If error occurs, it's mostly due to comminication. Check security groups, pay attention to both inbound and outbound.
- In order to be able to add more users, add a post install script. Check the adduser script.

```
cfncluster configure -c ~/.cfncluster/cfncluster.config
cfncluster create --norollback -c ~/.cfncluster/cfncluster.config vpchpc
cfncluster list
cfncluster delete vpchpc
```
