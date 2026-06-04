import json, sys
d = json.load(sys.stdin)
items = d["items"]
print("total items:", len(items))
rented = {"bankr-token-launch", "generate-playwright-tests", "git-changelog",
          "log-analyzer", "openclaude-loop", "schema-extract"}
print("=== inv | att | price | name | flags ===")
for s in items:
    att = s["stake"]["attestationCount"] if s.get("stake") else 0
    price = float(s["pricePerCall"])
    flag = []
    if s["name"] in rented:
        flag.append("RENTED")
    if price > 0.5:
        flag.append("OVERCAP")
    name = s["name"]
    inv = s["totalInvocations"]
    print(f"{inv:>2}inv  att={att}  ${price:<7} {name:<42} {','.join(flag)}")

print("\n=== CANDIDATES (not rented, <= 0.5 USDC), ranked ===")
cand = [s for s in items if s["name"] not in rented and float(s["pricePerCall"]) <= 0.5]
def key(s):
    att = s["stake"]["attestationCount"] if s.get("stake") else 0
    return (-s["totalInvocations"], -att, float(s["pricePerCall"]))
for s in sorted(cand, key=key):
    att = s["stake"]["attestationCount"] if s.get("stake") else 0
    print(f"{s['totalInvocations']:>2}inv  att={att}  ${float(s['pricePerCall']):<7} "
          f"{s['name']:<40} id={s['skillId']}")
