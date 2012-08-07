require "csv"

require "rsruby"
require "prawn"

require_relative "lib/olympics"

Olympics::Analysis.r = RSRuby.instance

EVENTS = [ ["1996", "Atlanta 1996 Summer Olympics"],
           ["2000", "Sydney 2000 Summer Olympics"],
           ["2004", "Athens 2004 Summer Olympics"],
           ["2008", "Beijing 2008 Summer Olympics"] ]


doc_options = { :page_layout        => :landscape,
                :skip_page_creation => true }

Prawn::Document.generate("olympic_report.pdf", doc_options) do |pdf|
  EVENTS.each do |year, title|
    csv = CSV.table("#{File.dirname(__FILE__)}/data/#{year}_combined.csv", 
                    :headers => true)
    csv.by_col!

    pdf.start_new_page
    Olympics::Report.new(csv, pdf).render(title)
  end
end
