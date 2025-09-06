#!/usr/bin/env ruby

require 'yaml'
require 'nokogiri'
require 'open-uri'
require 'active_support/all'

module Helpers
  extend ActiveSupport::NumberHelper
end

# Read bibliography file to get all papers with Google Scholar IDs
bib_file = File.read('_bibliography/papers.bib')
citations_data = {}

# Extract Google Scholar IDs from bib file
bib_file.scan(/@\w+{([^,]+),.*?google_scholar_id\s*=\s*{([^}]+)}/m) do |key, scholar_id|
  citations_data[key] = { 'google_scholar_id' => scholar_id, 'citation_count' => 'N/A' }
end

puts "Found #{citations_data.length} papers with Google Scholar IDs"

# Fetch citation counts
citations_data.each do |key, data|
  scholar_id = data['google_scholar_id']
  article_url = "https://scholar.google.com/citations?view_op=view_citation&hl=en&user=nMBhHf4AAAAJ&citation_for_view=nMBhHf4AAAAJ:#{scholar_id}"
  
  begin
    puts "Fetching citations for #{key} (ID: #{scholar_id})..."
    
    # Sleep to avoid rate limiting
    sleep(rand(2.0..4.0))
    
    # Fetch the page
    doc = Nokogiri::HTML(URI.open(article_url, "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"))
    
    # Extract citation count
    citation_count = 0
    
    # Look for meta tags
    description_meta = doc.css('meta[name="description"]')
    og_description_meta = doc.css('meta[property="og:description"]')
    
    if !description_meta.empty?
      cited_by_text = description_meta[0]['content']
      matches = cited_by_text.match(/Cited by (\d+[,\d]*)/)
      
      if matches
        citation_count = matches[1].sub(",", "").to_i
      end
    elsif !og_description_meta.empty?
      cited_by_text = og_description_meta[0]['content']
      matches = cited_by_text.match(/Cited by (\d+[,\d]*)/)
      
      if matches
        citation_count = matches[1].sub(",", "").to_i
      end
    end
    
    # Format the citation count
    formatted_count = Helpers.number_to_human(citation_count, :format => '%n%u', :precision => 2, :units => { :thousand => 'K', :million => 'M', :billion => 'B' })
    data['citation_count'] = formatted_count
    data['raw_count'] = citation_count
    data['last_updated'] = Time.now.strftime('%Y-%m-%d')
    
    puts "  -> #{formatted_count} citations"
    
  rescue Exception => e
    puts "  -> Error: #{e.message}"
    data['citation_count'] = 'N/A'
    data['error'] = e.message
  end
end

# Save to YAML file
File.write('_data/citations.yml', citations_data.to_yaml)
puts "\nCitation data saved to _data/citations.yml"