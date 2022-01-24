# aws-lambda-rust-cookie

Serverless cookie logger that searches for url location using `lambda_http`, `lambda_runtime`, and `ipgeolocate` crate. The code logs the result to AWS Cloudwatch and returns as response with the geolocation string. The Cloudwatch logs are disabled by default.



# Usage
Change code as needed specifically `main.rs` and `main.tf`. Additionally, if you want to enable logging in AWS CloudWatch, then change `"Effect" : "Deny"`
to `"Effect" : "Allow"` on line `104` of `main.tf`. You should be aware that this may incur costs from AWS, which is why I set the default to `Deny`.

After this is complete, and assuming you still want to use `ipgeolocate`, then run:
```
./compile.sh
```
to compile with cargo, copy the library files, and apply the terraform changes. A better recommendation would be to use terraform plan first though, rather than applying changes immediately. I used `-auto-approve` during development to save a few keystrokes :) but I don't recommend this.

# Implementation details
This code logs to AWS Cloudwatch but this is disabled in main.tf at the moment and the result is returned as a response packet. There were some issues getting the geolocation working in a MacOS environment due to problems with `ipgeolocate` and `openssl` and `opencrypto`. I found that the fastest way to address this was to launch a `Ubuntu VM` in `VirtualBox` and develop in this linux environment. Even so, I still needed to copy over `libssl.so.1.1` and `libcrypto.so.1.1` with the bootstrap file into the AWS lambda directory using amazon linux 2. A *__much__* better way to deal with this would be to add an OpenSSL layer to the lambda, like this https://jaredchu.com/fix-missing-openssl-on-aws-lambda-nodejs-10-x-12-x/. But in the interest of completing this example program in minimal time, I found that compiling with cargo on ubuntu and adding in the above library files to the bootstrap directory was sufficient. 


## License

Licensed under either of

 * Apache License, Version 2.0
   ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license
   ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

Additionally, license files have been added for `libssl.so.1.1` under the `libssl` directory, and `libcrypto.so.1.1` under the `libcrypto` directory.