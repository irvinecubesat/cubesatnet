# cubesatnet
[Irvine CubeSat](http://irvinecubesat.org) involves cooperation
between students from the six high schools in Irvine.  Hardware for
the project is distributed among the high schools and the CubeSatNet
VPN allows students, teachers, and mentors to access the servers and
hardware remotely in a secure manner.

If you are a Irvine CubeSat student, follow the
instructions here to establish your digital identity for Irvine
CubeSat and get access to the VPN and other resources.  The process
will involve generating a public/private key pair.  Keep your private
key, the `.key` file, secure and do not give it out to anyone.

# Generating your keys

Using git, clone the cubesatnet project and run the `make genKeys` command:
```
$ git clone https://github.com/irvinecubesat/cubesatnet.git
$ cd cubesatnet
$ make genKeys
```

Email the generated .cert file to your VPN administrator.

Once your administrator emails you back a .ovpnx file and a -cert.pub file,
put these files in the ~/.ssh directory.

# Connecting to the vpn

To connect to the vpn, run the vpnConnect.sh script.  In the cubesatnet
project directory, type:

```
$ scripts/vpnConnect.sh
```
