use regex::Regex;

pub fn clean_svg_header(svg_content: &str) -> String {
    // Regex Erklärung:
    // (?s)           -> Aktiviert "Dot matches newline" Modus (wichtig für mehrzeilige Header)
    // (
    //   <\?xml       -> Literal "<?xml" (Start der XML Deklaration)
    //   .*?          -> Beliebiger Inhalt (non-greedy, bis zum ersten ?>)
    //   \?>          -> Literal "?>" (Ende der XML Deklaration)
    // |              -> ODER
    //   <!DOCTYPE    -> Literal "<!DOCTYPE"
    //   .*?          -> Beliebiger Inhalt (non-greedy, bis zum ersten >)
    //   >            -> Literal ">" (Ende des DOCTYPE)
    // )
    let re = Regex::new(r"(?s)(<\?xml.*?\?>|<!DOCTYPE.*?>)").unwrap();

    // 1. Header entfernen
    let cleaned = re.replace_all(svg_content, "");
    
    // 2. Optional: Whitespace am Anfang/Ende trimmen (damit keine leeren Zeilen oben bleiben)
    cleaned.trim().to_string()
}
