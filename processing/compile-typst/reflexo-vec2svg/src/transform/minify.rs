use std::sync::Arc;

use reflexo::{hash::FxHashMap, TakeAs};

use crate::backend::{SvgText, SvgTextNode};

pub fn minify_one(text: &mut SvgText) -> bool {
    let content = match text {
        SvgText::Plain(_) => return false,
        SvgText::Content(content) => content,
    };

    let content = Arc::make_mut(content);

    if content.content.len() == 1
        && content.attributes.len() == 1
        && content.attributes[0].0 == "transform"
        && matches!(content.content[0], SvgText::Content(_))
    {
        // let transform = content.attributes[0].1.as_str();

        // eprintln!("minify_one fold transform: {:#?}", transform);
        // eprintln!("minify_one fold transform after: {:#?}", transform);

        let sub_content = match &mut content.content[0] {
            SvgText::Plain(_) => unreachable!(),
            SvgText::Content(content) => content.clone(),
        };

        content.content.clear();

        let sub_content = TakeAs::<SvgTextNode>::take(sub_content);

        content.content = sub_content.content;

        for (key, value) in sub_content.attributes {
            if key == "transform" {
                content.attributes[0].1 = format!("{}, {}", content.attributes[0].1, value);
                continue;
            }

            content.attributes.push((key, value));
        }

        *text = SvgText::Content(Arc::new(content.clone()));
        minify_one(text);
        return true;
    }

    let mut optimized = false;

    for text in content.content.iter_mut() {
        let sub = minify_one(text);
        if sub {
            optimized = true;
        }
    }

    if optimized {
        *text = SvgText::Content(Arc::new(content.clone()));
    }

    optimized
}

/// Do semantic-aware minification of SVG.
pub fn minify(mut svg: Vec<SvgText>) -> Vec<SvgText> {
    // eprintln!("minify_svg: {:#?}", svg);

    for text in svg.iter_mut() {
        minify_one(text);
    }

    if let Some(root) = svg.iter().find_map(|text| match text {
        SvgText::Plain(text) if text.starts_with("<svg") => Some(text),
        _ => None,
    }) {
        let mut top_level_namespaces = TopLevelNamespaces::from_text(root);
        for text in svg.iter_mut().skip(1) {
            match text {
                SvgText::Plain(text) => {
                    *text = resolve_namespace_conflicts(
                        &mut top_level_namespaces,
                        std::mem::take(text),
                    );
                }
                _ => {}
            }
        }
    }

    // eprintln!("minify_svg after: {:#?}", svg);
    svg
}

pub struct TopLevelNamespaces {
    namespaces: FxHashMap<String, String>,
    counter: usize,
}

impl TopLevelNamespaces {
    pub fn from_text(text: &str) -> Self {
        let namespaces = find_namespaces(text);
        Self {
            namespaces: FxHashMap::from_iter(namespaces),
            counter: 0,
        }
    }
}

pub fn resolve_namespace_conflicts(
    taken_namespaces: &mut TopLevelNamespaces,
    mut content: String,
) -> String {
    let found_namespaces = find_namespaces(&content);
    for (prefix, url) in found_namespaces {
        if taken_namespaces.namespaces.contains_key(&prefix) {
            if taken_namespaces.namespaces[&prefix] == url {
                content = delete_namespace_definition(&content, &prefix);
            } else {
                content = replace_namespace_prefix(&content, &prefix, &format!("ns{}", taken_namespaces.counter));
                taken_namespaces.counter += 1;
            }
        }
    }
    content
}

use regex::{Captures, Regex};

// Regex für XML Tags (Strikt, validiert Quotes via Alternation statt Backref)
// Pattern: < NAME (ATTR="VAL" | ATTR='VAL')* >
const STRICT_TAG_PATTERN: &str = r#"<(/?[a-zA-Z_:][\w:-]*)(?:\s+[a-zA-Z_:][\w:-]*\s*=\s*(?:'[^']*'|"[^"]*"))*\s*/?>"#;

fn find_namespaces(xml_text: &str) -> Vec<(String, String)> {
    let tag_re = Regex::new(STRICT_TAG_PATTERN).unwrap();
    
    // KORREKTUR: Alternation statt Backreference
    // Gruppe 1: Namespace Name
    // Gruppe 2: Wert in Double Quotes "..."
    // Gruppe 3: Wert in Single Quotes '...'
    let ns_re = Regex::new(r#"xmlns:([\w-]+)=(?:"([^"]*)"|'([^']*)')"#).unwrap();

    let mut namespaces = Vec::new();

    for tag_match in tag_re.find_iter(xml_text) {
        for cap in ns_re.captures_iter(tag_match.as_str()) {
            let name = cap[1].to_string();
            
            // Wir müssen schauen, welche Quote-Art gematcht hat (Gruppe 2 oder 3)
            let value = if let Some(m) = cap.get(2) {
                m.as_str().to_string()
            } else if let Some(m) = cap.get(3) {
                m.as_str().to_string()
            } else {
                String::new() // Sollte per Regex nicht passieren
            };

            namespaces.push((name, value));
        }
    }
    namespaces
}

fn replace_namespace_prefix(text: &str, old_prefix: &str, new_prefix: &str) -> String {
    let tag_re = Regex::new(STRICT_TAG_PATTERN).unwrap();
    
    // Pattern: prefix gefolgt von Doppelpunkt.
    // (?: ... ) ist eine non-capturing group, das ist in Rust erlaubt.
    let ns_pattern = format!(r#"((?:<|/|\s|xmlns:)){}(:)"#, regex::escape(old_prefix));
    let ns_re = Regex::new(&ns_pattern).unwrap();
    
    // Replacement nutzt ${1}, das ist erlaubt (Backref im Replacement String ist ok, nur nicht im Pattern)
    let replacement = format!("${{1}}{}${{2}}", new_prefix);

    tag_re.replace_all(text, |caps: &Captures| {
        ns_re.replace_all(&caps[0], replacement.as_str()).to_string()
    }).to_string()
}

fn delete_namespace_definition(text: &str, prefix_to_delete: &str) -> String {
    let tag_re = Regex::new(STRICT_TAG_PATTERN).unwrap();

    // Auch hier: Alternation statt Backref für die Quotes
    // Matche: Leerzeichen + xmlns:PREFIX + = + ("..." ODER '...')
    let pattern = format!(
        r#"\s+xmlns:{}\s*=\s*(?:'[^']*'|"[^"]*")"#, 
        regex::escape(prefix_to_delete)
    );
    let remove_re = Regex::new(&pattern).unwrap();

    tag_re.replace_all(text, |caps: &Captures| {
        remove_re.replace(&caps[0], "").to_string()
    }).to_string()
}
