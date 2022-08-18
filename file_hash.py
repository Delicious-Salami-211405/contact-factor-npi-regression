# SHA256 hash of report content

import hashlib

filename = 'The effect of non-pharmaceutical interventions on COVID-19 contact factors vF.docx'
with open(filename, 'rb') as f:
	h = hashlib.sha256(f.read()).hexdigest()

# Print SHA256 hash
print(h)