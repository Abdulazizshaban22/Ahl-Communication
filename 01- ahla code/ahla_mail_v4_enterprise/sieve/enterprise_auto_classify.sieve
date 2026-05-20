\
require ["fileinto", "imap4flags", "variables", "vnd.stalwart.expressions"];

# Use LLM to classify
set "subject" "thread_name(header.subject)";
set "body" "body.to_text";
# model id must match enterprise.ai.<id> in server config
set "resp" "llm_prompt('ahla-intel-local', 'Classify this email as one of [work,personal,promotion,gratitude,conflict,notification]. Reply with only the label.\n\nSubject: ' + subject + '\n\n' + body, 0.2)";

if anyof (string :is "${resp}" "promotion") { fileinto "Promotions"; stop; }
if anyof (string :is "${resp}" "gratitude") { fileinto "Gratitude"; stop; }
if anyof (string :is "${resp}" "conflict")  { fileinto "Escalations"; stop; }
if anyof (string :is "${resp}" "work")      { addflag "\\Work"; fileinto "Work"; stop; }
if anyof (string :is "${resp}" "personal")  { addflag "\\Personal"; fileinto "Personal"; stop; }
# defaults
# keep in Inbox
