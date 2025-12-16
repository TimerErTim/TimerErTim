use std::fs;
use std::path::PathBuf;
use std::sync::Arc;

use reflexo_typst::EntryState;
use reflexo_typst::LazyHash;
use reflexo_typst::TaskInputs;
use reflexo_typst::TypstDatetime;
use reflexo_typst::TypstPagedDocument;
use reflexo_typst::TypstSystemUniverse;
use reflexo_typst::args::CompileFontArgs;
use reflexo_typst::args::CompilePackageArgs;
use reflexo_typst::system::SystemUniverseBuilder;
use reflexo_vec2svg::SvgText;
use reflexo_vec2svg::{ExportFeature, SvgExporter, transform};
use typst::foundations::IntoValue;

fn main() -> anyhow::Result<()> {
    let verse = build_base_universe("README.typ")?;

    for theme in ["light", "dark"] {
        let world = verse.snapshot_with(Some(TaskInputs {
            inputs: Some(Arc::new(LazyHash::new(vec![
                ("theme".into(), theme.into_value()),
                ("now".into(), now().into_value())
            ].into_iter().collect()))),
            ..Default::default()
        }));
        let pages = typst::compile::<TypstPagedDocument>(&world)
        .output
        .map_err(|err| anyhow::anyhow!("Failed to compile typst: {:?}", err))?;

        let svg = render(&pages);
        fs::write(format!("dist/{theme}.svg"), svg).map_err(|err| anyhow::anyhow!("Failed to write SVG: {:?}", err))?;
    }

    Ok(())
}

pub fn now() -> TypstDatetime {
    let now = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap();
    let secs = now.as_secs();
    
    // Convert Unix timestamp to date/time components
    let days_since_epoch = secs / 86400;
    let seconds_today = secs % 86400;
    
    // Calculate year, month, day from days since epoch (1970-01-01)
    let mut year = 1970;
    let mut days_remaining = days_since_epoch;
    
    // Simple leap year calculation
    loop {
        let days_in_year = if year % 4 == 0 && (year % 100 != 0 || year % 400 == 0) { 366 } else { 365 };
        if days_remaining < days_in_year {
            break;
        }
        days_remaining -= days_in_year;
        year += 1;
    }
    
    // Days in each month (non-leap year)
    let days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    let mut month = 1;
    let mut days_in_current_month;
    
    for (i, &days) in days_in_month.iter().enumerate() {
        days_in_current_month = if i == 1 && year % 4 == 0 && (year % 100 != 0 || year % 400 == 0) {
            29 // February in leap year
        } else {
            days
        };
        
        if days_remaining < days_in_current_month {
            month = i + 1;
            break;
        }
        days_remaining -= days_in_current_month;
    }
    
    let day = days_remaining + 1;
    let hour = seconds_today / 3600;
    let minute = (seconds_today % 3600) / 60;
    let second = seconds_today % 60;
    
    TypstDatetime::from_ymd_hms(
        year as i32,
        month as u8,
        day as u8,
        hour as u8,
        minute as u8,
        second as u8,
    ).unwrap()
}

fn build_base_universe(source_path: impl Into<PathBuf>) -> anyhow::Result<TypstSystemUniverse> {
    let path = Arc::from(source_path.into());
    let fonts = SystemUniverseBuilder::resolve_fonts(CompileFontArgs::default())?;
    let package =
        SystemUniverseBuilder::resolve_package(None, Some(&CompilePackageArgs::default()));

    Ok(SystemUniverseBuilder::build(
        EntryState::new_rooted_by_parent(path).ok_or(anyhow::anyhow!("Failed to build entry state"))?,
        Default::default(),
        Arc::new(fonts),
        package,
    ))
}

struct EmbeddedSvgExportFeature;

impl ExportFeature for EmbeddedSvgExportFeature {
    const ENABLE_TRACING: bool = false;

    const SHOULD_ATTACH_DEBUG_INFO: bool = false;

    const ENABLE_INLINED_SVG: bool = true;

    const SHOULD_RENDER_TEXT_ELEMENT: bool = true;

    const USE_STABLE_GLYPH_ID: bool = true;

    const SHOULD_RASTERIZE_TEXT: bool = false;

    const WITH_BUILTIN_CSS: bool = true;

    const WITH_RESPONSIVE_JS: bool = false;

    const AWARE_HTML_ENTITY: bool = false;
}

pub fn render(pages: &TypstPagedDocument) -> String {
    render_svg::<EmbeddedSvgExportFeature>(pages)
}

/// Render SVG for [`TypstPagedDocument`].
pub fn render_svg<EF: ExportFeature>(pages: &TypstPagedDocument) -> String {
    let mut doc = SvgExporter::<EF>::svg_doc(pages);
    doc.module.prepare_glyphs();
    let svg_text = SvgExporter::<EF>::render(&doc.module, &doc.pages, None);
    generate_text(transform::minify(svg_text))
}

/// Concatenate a list of [`SvgText`] into a single string.
pub fn generate_text(text_list: Vec<SvgText>) -> String {
    let mut string_io = String::new();
    string_io.reserve(text_list.iter().map(SvgText::estimated_len).sum());
    for s in text_list {
        s.write_string_io(&mut string_io);
    }
    string_io
}
