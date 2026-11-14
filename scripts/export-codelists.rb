# frozen_string_literal: true

# Standalone port of CodelistPagesGenerator#parse_catalogue — emits
# codelists_index.json consumed by the Astro codelist routes.
require "json"
require "rexml/document"

CODELIST_XML = File.join(__dir__, "..", "schemas", "resources", "codelists", "codelists.xml")

def scoped_text(element, child)
  el = element.elements["cat:#{child}/gco:ScopedName"]
  el&.text
end

def char_text(element, child)
  el = element.elements["cat:#{child}/gco:CharacterString"]
  el&.text
end

def extract_values(cl)
  result = []
  cl.elements.each("cat:codeEntry/cat:CT_CodelistValue") do |entry|
    entry_id = entry.attributes["id"]
    next unless entry_id
    result << {
      "id" => entry_id,
      "identifier" => scoped_text(entry, "identifier") || entry_id,
      "name" => scoped_text(entry, "name"),
      "definition" => char_text(entry, "definition"),
      "description" => char_text(entry, "description"),
    }
  end
  result
end

def build_codelist_entry(cl)
  id = cl.attributes["id"]
  return nil unless id
  {
    "id" => id,
    "name" => scoped_text(cl, "name") || id,
    "identifier" => scoped_text(cl, "identifier") || id,
    "definition" => char_text(cl, "definition"),
    "description" => char_text(cl, "description"),
    "values" => extract_values(cl),
  }
end

def collect_codelists(element)
  result = []
  element.elements.each("cat:codelistItem/cat:CT_Codelist") do |cl|
    entry = build_codelist_entry(cl)
    result << entry if entry
  end
  element.elements.each("cat:subCatalogue/cat:CT_CodelistCatalogue") do |sub|
    result.concat(collect_codelists(sub))
  end
  result
end

doc = REXML::Document.new(File.read(CODELIST_XML))
catalogue = doc.root ? collect_codelists(doc.root) : []
File.write(File.join(__dir__, "..", "codelists_index.json"), JSON.pretty_generate(catalogue))
puts "codelists_index.json: #{catalogue.size} codelists"
