# Scp Copy
```bash
scp -i /path/to/key.pem -r /path/to/file ec2-user@123.12.12.12:/home/ubuntu/
```
# Tunnel
```bash
ssh -i <path/to/ssh-key.pem> -N -L <local_port>:<dest_host>:<dest_port> <user_ubuntu>@<ipaddr1.1.1.1>
```
# Open SSL check
`openssl s_client -connect api.domain.com:443 -tls1`

`nmap -Pn -p 443 api-webst.decimated.net --script ssl-enum-ciphers`
