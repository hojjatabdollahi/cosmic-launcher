use std::{env, fs, path::Path};
use xdgen::{App, Context, FluentString};

fn main() {
    let ctx = Context::new("i18n", env::var("CARGO_PKG_NAME").unwrap()).unwrap();
    let app = App::new(FluentString("app-title"))
        .comment(FluentString("app-comment"))
        .keywords(FluentString("app-keywords"));

    let desktop_entry = app.expand_desktop("data/com.system76.CosmicLauncher.desktop", &ctx).unwrap();
    let metainfo = app
        .expand_metainfo("data/com.system76.CosmicLauncher.metainfo.xml", &ctx)
        .unwrap();

    let output = Path::new("target/xdgen/");
    fs::create_dir_all(output).unwrap();
    fs::write(output.join("com.system76.CosmicLauncher.desktop"), desktop_entry).unwrap();
    fs::write(output.join("com.system76.CosmicLauncher.metainfo.xml"), metainfo).unwrap();
}
