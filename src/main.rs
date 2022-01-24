use ipgeolocate::{Locator, Service};
use lambda_http::{
    handler,
    lambda_runtime::{self, Context, Error},
    IntoResponse, Request,
};

#[macro_use]
extern crate log;
extern crate simple_logger;

#[tokio::main]
async fn main() -> Result<(), Error> {
    simple_logger::init_with_level(log::Level::Info)?;
    info!("Logging started.");
    lambda_runtime::run(handler(func)).await?;
    Ok(())
}

async fn func(event: Request, _context: Context) -> Result<(), Error> {
    let service = Service::IpApi;
    let ip_string = format!(
        "{:?}",
        event
            .headers()
            .get("x-forwarded-for")
            .expect("No source ip found")
    )
    .replace("\"", "");

    info!("ip_string = {}", &ip_string);
    let response_string = match Locator::get(&ip_string, service).await {
        Ok(ip) => format!("{} - {} ({})", ip.ip, ip.city, ip.country),
        Err(error) => {
            error!("Source lookup failed: {}", error);
            format!("Source lookup failed: {}", error)
        }
    };
    
    info!("response_string = {}", &response_string);
    // Ok(response_string.into_response())
    Ok(())
}
