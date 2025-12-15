fn main() {
    
}

/// Render SVG for [`TypstPagedDocument`].
pub fn render_svg(pages: &TypstPagedDocument) -> String {
    type UsingExporter = SvgExporter<SvgExportFeature>;
    let mut doc = UsingExporter::svg_doc(pages);
    doc.module.prepare_glyphs();
    let svg_text = UsingExporter::render(&doc.module, &doc.pages, None);
    generate_text(transform::minify(svg_text))
}
