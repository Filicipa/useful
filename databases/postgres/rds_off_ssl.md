`?sslmode=no-verify`

### Parameter groups RDS
```
rds.force_ssl=0
pgtle.enable_clientauth=on
```

### CONNECTIONS
`max_connections=200`

### SSL
Modify the `rds.force_ssl` Parameter of your new Parameter Group:
In the list of parameter groups, click on the name of the new parameter group you just created.

In the "Filter parameters" box, type `rds.force_ssl` and press Enter.

You should see the `rds.force_ssl` parameter. Click "Edit parameters".

Change the value of `rds.force_ssl` from `1` to `0`, then click "Save changes".