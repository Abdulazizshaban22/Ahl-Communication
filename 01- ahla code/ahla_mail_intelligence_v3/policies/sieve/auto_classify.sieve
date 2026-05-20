\
require ["fileinto","imap4flags","variables","regex","envelope","environment"];

# Promotions by header
if header :contains "List-Unsubscribe" "<" {
  fileinto "Promotions"; stop;
}

# LLM header mapping
if header :matches "X-Ahla-LLM" "*label=promotion*" { fileinto "Promotions"; stop; }
if header :matches "X-Ahla-LLM" "*label=gratitude*" { fileinto "Gratitude"; stop; }
if header :matches "X-Ahla-LLM" "*label=conflict*"  { fileinto "Escalations"; stop; }
if header :matches "X-Ahla-LLM" "*label=work*"      { addflag "\\Work"; fileinto "Work"; stop; }
if header :matches "X-Ahla-LLM" "*label=personal*"  { addflag "\\Personal"; fileinto "Personal"; stop; }
