use std::path::{Path, PathBuf};
use std::{env, fs};
use xdgen::{App, Context, FluentString};

fn main() {
    let ctx = Context::new("i18n", env::var("APP_NAME").unwrap()).unwrap();
    let app = App::new(FluentString("xdg-title"))
        .comment(FluentString("xdg-comment"))
        .keywords(FluentString("xdg-keywords"));

    let app_id = env::var("APP_ID").unwrap();
    let app_data = env::var("APP_DATA").unwrap_or_else(|_| String::from("data"));

    let output = Path::new("target/xdgen/");

    let desktop_entry_path = PathBuf::from(format!("{app_data}/{app_id}.desktop"));
    if desktop_entry_path.exists() {
        let desktop_entry = app.expand_desktop(desktop_entry_path, &ctx).unwrap();
        fs::create_dir_all(output).unwrap();
        fs::write(output.join(format!("{app_id}.desktop")), desktop_entry).unwrap();
    }

    let metainfo_path = PathBuf::from(format!("{app_data}/{app_id}.metainfo.xml"));
    if metainfo_path.exists() {
        let metainfo = app.expand_metainfo(metainfo_path, &ctx).unwrap();
        fs::write(output.join(format!("{app_id}.metainfo.xml")), metainfo).unwrap();
    }
}
