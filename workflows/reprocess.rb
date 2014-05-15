require_relative '../settings'

require 'logger'
require 'progressbar'

# An array of acronyms to restrict parsing to these particular ontologies
def get_submissions(type)
  puts "Gathering ontologies of type #{type}"
  subs = []
  LinkedData::Models::Ontology.where.include(:acronym, :summaryOnly).all.each do |ont|
    if !ont.summaryOnly
      sub = ont.latest_submission(status: :any)
      if sub
        sub.bring(:hasOntologyLanguage)
        if type == "obo" && sub.hasOntologyLanguage.obo?
          subs << sub
        end
        if type == "umls" && sub.hasOntologyLanguage.umls?
          subs << sub
        end
        if type == "owl" && sub.hasOntologyLanguage.owl?
          subs << sub
        end
      end
    end
  end
  puts "Found #{subs.length} #{type} ontologies"
  return subs
end

submissions = []
#acronyms.each do |acr|
#  submissions << LinkedData::Models::Ontology.find(acr).first.latest_submission(status: :any)
#end
submissions = get_submissions("umls")

binding.pry
puts "", "Parsing #{submissions.length} submissions..."
pbar = ProgressBar.new("Parsing", submissions.length)
FileUtils.mkdir_p("./parsing")
submissions.each do |s|
  s.bring_remaining
  s.bring(ontology: [:acronym])
  log_file = File.open("./parsing/parsing_#{s.ontology.acronym}.log", "w")
  logger = Logger.new(log_file)
  logger.level = Logger::DEBUG
  begin
    s.process_submission(logger,
                          process_rdf: true, index_search: true,
                          run_metrics: true, reasoning: true)
  rescue Exception => e
    binding.pry
  end
  pbar.inc
end