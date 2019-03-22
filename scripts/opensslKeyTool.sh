#!/bin/bash
#
# Tool to manage openssl keys
#
keyDir=~/.ssh
commonName=$(whoami)

keyInfoFile=~/.irvinecubesat.keyInfo
if [ -e "$keyInfoFile" ]; then
    # shellcheck disable=SC1090
    . "$keyInfoFile"
fi

log()
{
    echo "$*"
}

usage()
{
    cat <<EOF
Usage:  $0 [options] {key file(s)} ...

        Tool to create/utilize openssl certificates and public keys
        for public key cryptography

Options
    -i           Interactive creation of key name and key setup
    -g {keyName} Generate a new self-signed cert with public/private keys
    -e {file}    Encrypt the input file with public certifcates  
    -d {file}    decrypt the input file with private key 
    -o {file}    specify the output file (Default stdout)
    -k {dir}     Keystore directory (Default: $keyDir)
    -c {CN}      The common name (CN) for cert generation(Default:  ${commonName}))
    -n {keyName} Use keyname (Default:  $keyName)
    -p           Extract the public key from the cert
    -f {cfgfile} File to store cert params/initialze params
EOF
    exit 1
}


unset outputFile

while getopts "g:e:d:k:n:c:g:o:if:ph" arg; do
    case $arg in
	i)
	    cmd="gen"
	    unset keyName
	    ;;
        g)
            cmd="gen"
            keyName=$OPTARG
            ;;
        e)
            cmd="enc"
            inputFile=$OPTARG
            ;;
        d)
            cmd="dec"
            inputFile=$OPTARG
            ;;
        c)
            commonName=$OPTARG
            ;;
        n)
            keyName=$OPTARG
            ;;
        k)
            keyDir=$OPTARG
            ;;
        o)
            outputFile=$OPTARG
            ;;
        f)
            cfgFile=$OPTARG
            if [ -n "$cfgFile" ] && [ -f "$cfgFile" ]; then
                # shellcheck disable=SC1090
                . "$cfgFile"
            fi
            ;;
        p)
            cmd="pubkey"
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done
shift "$((OPTIND-1))"

if [ -n "$outputFile" ]; then
    outputArg="-out $outputFile"
fi

promptUserForKeyName()
{
    while [ ! "ok" = "$ok" ]; do
       echo "What is your First Name?" 
       read firstName
       echo "What is your Last Name?"
       read lastName
       if [ -z "$firstName" ] || [ -z "$lastName" ]; then
	   echo "First and Last Name are mandatory"
	   continue
       fi
       echo "Enter an optional key suffix to help you identify your key"
       read keySuffix
       
       keyName="$firstName-$lastName-$keySuffix-irvinecubesat"
       echo "Is this keyName ok:  $keyName? (y/N)"
       read keyNameOk
       if [ "$keyNameOk" = "y" ] || [ "$keyNameOk" = "Y" ]; then
	   ok="ok" 
	   break;
       fi
   done
}

genPubKey()
{
    key=${keyDir}/${keyName}.key
    cert=${keyDir}/${keyName}.cert
    pubkey=${key}.pub
    openssl x509 -pubkey -noout -in "$cert"|ssh-keygen -f /dev/stdin -i -m PKCS8|sed -e "1 s/\$/ $keyName/">"$pubkey"
}

case $cmd in
    gen)
	if [ -z "${keyName}" ]; then
	    promptUserForKeyName
	fi
        if [ -n "$cfgFile" ] && [ -n "${keyName}" ] && [ -n "$keyDir" ]; then
            {
                echo "keyName=${keyName}"
                echo "keyDir=${keyDir}"
            } > "$cfgFile"
        fi
        mkdir -p "${keyDir}"
        chmod 700 "${keyDir}"
        keyPath="${keyDir}/${keyName}.key"
	if [ -e "$keyPath" ]; then
	    echo "Your key already exists at: $keyPath."
	    exit 0
	fi
        openssl req -x509 -newkey rsa:4096 -days 3650 -nodes -subj "/C=US/ST=*/L=*/O=*/OU=*/CN=${commonName}/" -keyout "$keyPath" -out "${keyDir}/${keyName}.cert"
        exitStatus=$?
        if ! chmod 600 "$keyPath"; then
            log "[E] Unable to set permissions on $keyPath"
        fi
	genPubKey
    ;;
    enc)
        if [ -n "$*" ]; then
            keys="$*"
        else
            keys="${keyDir}/${keyName}.cert"
        fi
        # shellcheck disable=SC2086
        openssl smime -encrypt -aes256 -in "$inputFile" $outputArg -outform PEM $keys
        exitStatus=$?
        ;;
    dec)
        if [ -n "$1" ]; then
            key="$1"
        else
            key=${keyDir}/${keyName}.key
        fi

        # shellcheck disable=SC2086
        openssl smime -decrypt -in "$inputFile" -inform PEM -inkey "$key" $outputArg
        exitStatus=$?
        if [ $exitStatus -ne 0 ]; then
            log "[E] Unable to decrypt $inputFile with $key"
            # cleanup output file
            if [ -n "$outputFile" ]; then
                rm "$outputFile"
            fi
        fi
        ;;
    pubkey)
	genPubKey
        ;;
    *)
        log "[E] Unknown cmd:  $cmd"
        exit 1
        ;;
esac

exit $exitStatus

