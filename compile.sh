#! /bin/sh

cargo build --release
file="bootstrap.zip"

if [ -f "$file" ] ; then
    rm "$file"
fi
cp ./target/release/bootstrap .
zip bootstrap.zip bootstrap libssl.so.1.1 libcrypto.so.1.1
terraform apply
