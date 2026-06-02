import json
d = json.load(open('.atrium_all.json'))
print('TOTAL:', d.get('total'))
for x in d['items']:
    print('%-26s | $%-7s | inv=%-3s | earned=$%-6s | cats=%s | tags=%s | %s' % (
        x['name'], x['pricePerCall'], x['totalInvocations'], x['totalEarned'],
        x.get('categories'), x.get('tags'), x['skillId'][:12]))
