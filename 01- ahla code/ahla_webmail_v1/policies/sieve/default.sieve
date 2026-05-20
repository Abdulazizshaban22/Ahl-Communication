require ["fileinto","imap4flags","regex","variables"];

# مثال: تصنيف ترويجي
if anyof (header :contains "List-Unsubscribe" "<", header :matches "From" "*promo*") {
  fileinto "Promotions";
  stop;
}

# مثال: عمل
if address :domain "from" "corp.com" {
  addflag "\\Work"; fileinto "Work"; stop;
}

# مثال: شخصي
if address :domain "from" "family.com" {
  addflag "\\Personal"; fileinto "Personal"; stop;
}

# لاحقًا: أضف وسم من LLM عبر هيدر مخصص X-Ahla-LLM:label=...
if header :contains "X-Ahla-LLM" "label=gratitude" {
  fileinto "Gratitude";
}
