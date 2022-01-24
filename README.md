# aws-lambda-rust-cookie

Serverless cookie logger that searches for url location using `lambda_http`, `lambda_runtime`, and `ipgeolocate` crate. This code also logs to AWS Cloudwatch but this is disabled in main.tf at the moment. There were some issues getting this working in a MacOS environment due to issues with `ipgeolocate` and `openssl` and `opencrypto`. I found that the fastest way to address this was to launch a `Ubuntu VM` in `VirtualBox` and develop in this linux environment. Even so, I still needed to copy over `libssl.so.1.1` and `libcrypto.so.1.1` with the bootstrap file into the AWS lambda directory using amazon linux 2. A better way to deal with this would be to add an OpenSSL layer to the lambda, like this https://jaredchu.com/fix-missing-openssl-on-aws-lambda-nodejs-10-x-12-x/. But in the interest of completing this example program in minimal time, I found that compiling with cargo on ubuntu and adding in the above two library files to the bootstrap directory was sufficient. This API only returns the geolocation data and does not save it. This was sufficient for proof-of-concept and saving the result would be a simple extension. Additionally, turning on logs allows direct access to the return value so the data could be directly extracted from the logs without additional storage.


# Usage
Change code as needed specifically `main.rs` and `main.tf`. Additionally, if you want to enable logging in AWS CloudWatch, the you will need to change `"Effect" : "Deny"`
to `"Effect" : "Allow"` on line `104` of `main.tf`. You should be aware that this may incurr costs from AWS, which is why I set the default to `Deny`.

After this is complete, and assuming you still want to use `ipgeolocate`, then run:
```
./compile.sh
```
to compile with cargo, copy the library files, and apply the terraform changes. A better recommendation would be to use terraform plan first though, rather than applying changes immediately. I used `-auto-approve` during development to save a few keystrokes :) but I don't recommend this.

## License

Licensed under either of

 * Apache License, Version 2.0
   ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license
   ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

Additionally, license files have been added for `libssl.so.1.1` under the `libssl` directory, and `libcrypto.so.1.1` under the `libcrypto` directory.