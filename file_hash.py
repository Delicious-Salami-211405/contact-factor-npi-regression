# SHA256 hash of report content

import hashlib

filename = 'Project Report.docx'
with open(filename, 'rb') as f:
	h = hashlib.sha256(f.read()).hexdigest()

# Print SHA256 hash
print(h)