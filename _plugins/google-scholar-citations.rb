require "active_support/all"
require 'nokogiri'
require 'open-uri'
require 'yaml'

module Helpers
  extend ActiveSupport::NumberHelper
end

module Jekyll
  class GoogleScholarCitationsTag < Liquid::Tag
    Citations = { }
    @@cached_citations = nil

    def initialize(tag_name, params, tokens)
      super
      splitted = params.split(" ").map(&:strip)
      @scholar_id = splitted[0]
      @article_id = splitted[1]
      @entry_key = splitted[2] if splitted.length > 2
    end

    def load_cached_citations
      return @@cached_citations if @@cached_citations

      citations_file = '_data/citations.yml'
      if File.exist?(citations_file)
        begin
          @@cached_citations = YAML.load_file(citations_file) || {}
        rescue
          @@cached_citations = {}
        end
      else
        @@cached_citations = {}
      end
      
      @@cached_citations
    end

    def render(context)
      article_id = context[@article_id.strip]
      scholar_id = context[@scholar_id.strip]
      entry_key = @entry_key ? context[@entry_key.strip] : nil

      # Check if we already have this citation in memory
      if GoogleScholarCitationsTag::Citations[article_id]
        return GoogleScholarCitationsTag::Citations[article_id]
      end

      # Load cached citations
      cached_data = load_cached_citations

      # First, try to use cached data if available (use entry_key for lookup)
      if entry_key && cached_data.key?(entry_key) && cached_data[entry_key]['citation_count']
        citation_count = cached_data[entry_key]['citation_count']
        puts "Using cached citation count for #{entry_key}: #{citation_count}"
        GoogleScholarCitationsTag::Citations[article_id] = citation_count
        return "#{citation_count}"
      end

      # Second, try to find cached data by Google Scholar ID
      cached_data.each do |key, value|
        if value['google_scholar_id'] == article_id && value['citation_count']
          citation_count = value['citation_count']
          puts "Using cached citation count for #{key} (matched by Scholar ID): #{citation_count}"
          GoogleScholarCitationsTag::Citations[article_id] = citation_count
          return "#{citation_count}"
        end
      end

      article_url = "https://scholar.google.com/citations?view_op=view_citation&hl=en&user=#{scholar_id}&citation_for_view=#{scholar_id}:#{article_id}"

      begin
          # Sleep for a random amount of time to avoid being blocked
          sleep(rand(1.5..3.5))

          # Fetch the article page
          doc = Nokogiri::HTML(URI.open(article_url, "User-Agent" => "Ruby/#{RUBY_VERSION}"))

          # Attempt to extract the "Cited by n" string from the meta tags
          citation_count = 0

          # Look for meta tags with "name" attribute set to "description"
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

        citation_count = Helpers.number_to_human(citation_count, :format => '%n%u', :precision => 2, :units => { :thousand => 'K', :million => 'M', :billion => 'B' })

      rescue Exception => e
        # Handle any errors that may occur during fetching
        puts "Error fetching citation count for #{article_id}: #{e.class} - #{e.message}"

        # Try to use cached data if available (fallback with entry_key)
        if entry_key && cached_data.key?(entry_key) && cached_data[entry_key]['citation_count']
          citation_count = cached_data[entry_key]['citation_count']
          puts "Using cached citation count for #{entry_key}: #{citation_count}"
        elsif cached_data.key?(article_id) && cached_data[article_id]['citation_count']
          citation_count = cached_data[article_id]['citation_count']
          puts "Using cached citation count for #{article_id}: #{citation_count}"
        else
          citation_count = "N/A"
        end
      end

      GoogleScholarCitationsTag::Citations[article_id] = citation_count
      return "#{citation_count}"
    end
  end
end

Liquid::Template.register_tag('google_scholar_citations', Jekyll::GoogleScholarCitationsTag)
