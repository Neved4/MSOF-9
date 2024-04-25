#!/usr/bin/env python3

import sys, re, pypdf

def search_pdf(regex, path):
	matches = []

	with open(path, 'rb') as file:
		reader = pypdf.PdfReader(file)

		for page_num in range(len(reader.pages)):
			text = reader.get_page(page_num).extract_text()
			matches.extend(re.findall(regex, text))

	return matches

if __name__ == "__main__":
	if len(sys.argv) != 3:
		print("Usage: python3 get_id.py <regex> <path>")
		sys.exit(1)

	regex = sys.argv[1]
	path = sys.argv[2]
	result = search_pdf(regex, path)

	for res in result:
		print(res)
