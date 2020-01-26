def get_command_line_argument
if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

domain = get_command_line_argument
dns_raw = File.readlines("zone")
dns_records=Hash.new
lookup_chain=Array.new
def parse_dns(filedata)
    local_hash=Hash.new
    filedata.each do |record|
        record_array=Array.new
        record.split(",").each do|splitted_rec|
            record_array.push(splitted_rec.strip)
        end
        local_hash[record_array[1]]={"record_type"=>record_array[0],"destination"=>record_array[2].to_s}
    end
    return local_hash
end

def resolve(dns_rec_hash,lookup_array,domain_to_search)
    if(dns_rec_hash[domain_to_search].nil?)
        lookup_array.push("Not found")
        return lookup_array    
    elsif(dns_rec_hash[domain_to_search]["record_type"].to_s=="CNAME")
        lookup_array.push(dns_rec_hash[domain_to_search]["destination"])
        resolve(dns_rec_hash,lookup_array,dns_rec_hash[domain_to_search]["destination"])
    elsif(dns_rec_hash[domain_to_search]["record_type"].to_s=="A")
        lookup_array.push(dns_rec_hash[domain_to_search]["destination"])
        return lookup_array
    end
end

dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join("=>")