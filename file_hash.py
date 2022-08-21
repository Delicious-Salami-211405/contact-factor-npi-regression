# SHA256 hash of report content

import hashlib

filename = '[211405] The effect of non-pharmaceutical interventions on COVID-19 contact factors vF2.docx'
with open(filename, 'rb') as f:
	h = hashlib.sha256(f.read()).hexdigest()

# Print SHA256 hash
print(h)