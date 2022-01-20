/*  shout out to https://www.youtube.com/watch?v=wlVcso4Ut5o
    and https://www.youtube.com/watch?v=PmtwtK6jyLc and the docs for
    lambda_http, lambda_runtime, and terraform that helped get me up and running
    in a few days.
*/

// use std::collections::HashMap;


use lambda_http::{
    handler,
    lambda_runtime::{self, Context, Error},
    IntoResponse, Request,
};
use ipgeolocate::{Locator, Service};


#[tokio::main]
async fn main() -> Result<(), Error> {
    lambda_runtime::run(handler(func)).await?;
    Ok(())
}

async fn func(event: Request, _context: Context) -> Result<impl IntoResponse, Error> {
    
    let service = Service::IpApi;
    let ip_string = format!(
        "{:?}",
        event
            .headers()
            .get("x-forwarded-for")
            .expect("No source ip found")
    );
    let response_string =match Locator::get(&ip_string, service).await {
        Ok(ip) => format!("{} - {} ({})", ip.ip, ip.city, ip.country),
        Err(error) => format!("Source lookup failed: {}", error),
    };
    Ok(response_string.into_response())
}
